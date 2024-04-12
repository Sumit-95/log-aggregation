locals {
  aws_business_entitiy = lower(element(split("-", data.aws_iam_account_alias.current.account_alias), 1))
  aws_account          = lower(element(split("-", data.aws_iam_account_alias.current.account_alias), 2))
  environment_type     = lower(element(split("-", data.aws_iam_account_alias.current.account_alias), 3))
  project_name         = "${var.service_name}-splunk"

  iam_role_for_step_function_arn = format("arn:aws:iam::%s:role/%s-%s-%s-%s-step-function-role", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

  cloudwatch_event_rule_name = format("%s-%s-%s-%s-cloudwatch-event-rule", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

  cloudwatch_event_rule_description = format("This CloudWatch Event Rule to trigger the Splunk Step Function (%s) which will ingest the GuardDuty Findings", module.step_function.step_function_arn)

  step_function_name               = format("%s-%s-%s-%s-step-function-to-orchestration-flow", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  lambda_function_name             = format("%s-%s-%s-%s-lambda-function-to-ingest-logs", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  sqs_queue_name                   = format("%s-%s-%s-%s-sqs-queue-to-manage-failover", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  sns_topic_name                   = format("%s-%s-%s-%s-sns-topic", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  iam_role_for_lambda_function_arn = format("arn:aws:iam::%s:role/%s-%s-%s-%s-lambda-function-role", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

  step_function_arn   = format("arn:aws:states:*:%s:stateMachine:%s-%s-%s-%s-step-function-to-orchestration-flow", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  lambda_function_arn = format("arn:aws:lambda:*:%s:function:%s-%s-%s-%s-lambda-function-to-ingest-logs", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  sqs_queue_arn       = format("arn:aws:sqs:*:%s:%s-%s-%s-%s-sqs-queue-to-manage-failover", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  sns_topic_arn       = format("arn:aws:sns:*:%s:%s-%s-%s-%s-sns-topic", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)


  admin_account_mapping = {
    # CETDEV
    "668764830176" = {
      admin_account_id        = "805097478809"
      admin_organization_role = "bsl-cetdev-logging-gd-splunk-describe-organizations-role"
      project_code            = "01257-200"
    }

    # CETTEST
    "178111371884" = {
      admin_account_id        = "678216654380"
      admin_organization_role = "bsl-cettest-logging-gd-splunk-describe-organizations-role"
      project_code            = "01257-200"
    }

    # MASTER
    "229415471955" = {
      admin_account_id        = "725799391269"
      admin_organization_role = "bsl-master-logging-gd-splunk-describe-organizations-role"
      project_code            = "01257-000"
    }
  }

  common_tags = tomap(
    {
      "ApplicationName"     = "splunk-ingestion-service",
      "ApplicationID"       = var.application_id,
      "CostCentre"          = var.cost_centre,
      "ManagedBy"           = "CET",
      "ProjectCode"         = lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "project_code"),
      "Automation"          = "N/A",
      "Environment"         = upper(local.environment_type),
      "Owner"               = "CloudEngineering@lseg.com",
      "Region"              = data.aws_region.current.name,
      "Reason"              = "splunk-ingestion-service",
      "mnd-applicationid"   = lower(var.application_id),
      "mnd-applicationname" = "splunk-ingestion-service",
      "mnd-owner"           = "cloudopsdl@lseg.com",
      "mnd-supportgroup"    = "bsl cloud ops",
      "mnd-projectcode"     = lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "project_code"),
      "mnd-costcentre"      = "cc51256",
      "mnd-envtype"         = lower(local.environment_type),
      "mnd-envsubtype"      = "na",
      "opt-managedby"       = "cet"
    }
  )


  definition = <<EOF
  {
    "StartAt": "Invoke",
    "States": {
      "Invoke": {
        "Type": "Task",
        "Resource": "${module.lambda.lambda_arn}",
        "Retry": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "BackoffRate": 2,
            "IntervalSeconds": 60,
            "Comment": "Retrier the Lambda Three Times",
            "MaxAttempts": 3
          }
        ],
        "Catch": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "Next": "SendToDLQ",
            "ResultPath": null,
            "Comment": "After Retry Send the Logs to SQS"
          }
        ],
        "End": true,
        "ResultPath": null
      },
      "SendToDLQ": {
        "Type": "Task",
        "Resource": "arn:aws:states:::sqs:sendMessage",
        "Parameters": {
          "QueueUrl": "${module.sqs.sqs_queue_url}",
          "MessageBody.$": "$"
        },
        "Next": "SNS Publish",
        "ResultPath": null
      },
      "SNS Publish": {
        "Type": "Task",
        "Resource": "arn:aws:states:::sns:publish",
        "Parameters": {
          "TopicArn": "${module.sns.sns_topic_arn}",
          "Message": {
            "Attention": "[Failed to Ingest Guard Duty Findings to Splunk]",
            "Environment": "[${local.environment_type}]",
            "Findings.$": "$"
          }
        },
        "End": true,
        "ResultPath": null
      }
    },
    "Comment": "Guard Duty Findings - Ingest Logs to Splunk Service"
  }
  EOF

  splunk_hec_url_mapping = {
    "cetdev" = {
      splunk_hec_url = "https://http-inputs-greywolf.splunkcloud.com:443/services/collector"
    }

    "cettest" = {
      splunk_hec_url = "https://http-inputs-greywolf.splunkcloud.com:443/services/collector"
    }

    "prod" = {
      splunk_hec_url = "https://http-inputs-redwolf.splunkcloud.com:443/services/collector"
    }
  }

  splunk_hec_token_name = format("%s-%s-%s-%s-secret", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)


  //eventrbrige patterns


  central_waf_bucket_name      = format("bsl-%s-logging-waf-event-logs-s3", local.environment_type)
  regional_r53_log_bucket_name = format("bsl-logging-%s-%s-r53-log-bucket", local.environment_type, data.aws_region.current.name)

  service_specific_vars = {
    gd = {
      event_pattern = jsonencode({
        detail-type = [
          "GuardDuty Finding"
        ],
        source = ["aws.guardduty"]
      })
    }
    waf = {
      event_pattern = jsonencode(
        {
          "source" : ["aws.s3"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["s3.amazonaws.com"],
            "eventName" : ["PutObject"],
            "requestParameters" : {
              "bucketName" : [local.central_waf_bucket_name]
            }
          }
        }
      )
    }
    r53 = {
      event_pattern = jsonencode(
        {
          "source" : ["aws.s3"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["s3.amazonaws.com"],
            "eventName" : ["PutObject"],
            "requestParameters" : {
              "bucketName" : [local.regional_r53_log_bucket_name]
            }
          }
        }
      )
    }
  }
}