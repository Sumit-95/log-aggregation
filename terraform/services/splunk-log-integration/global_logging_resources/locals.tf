locals {


  aws_business_entitiy = lower(element(split("-", data.aws_iam_account_alias.current.account_alias), 1))
  aws_account          = lower(element(split("-", data.aws_iam_account_alias.current.account_alias), 2))
  environment_type     = lower(element(split("-", data.aws_iam_account_alias.current.account_alias), 3))
  project_name         = "${var.service_name}-splunk"

  admin_account_mapping = {
    # CETDEV
    "668764830176" = {
      admin_account_id        = "805097478809"
      admin_organization_role = "bsl-cetdev-logging-${var.service_name}-splunk-describe-organizations-role"
      project_code            = "01257-200"
      vault_secret_path       = format("secret/cet/splunk/%s/gray_wolf", var.service_name)
    }

    # CETTEST
    "178111371884" = {
      admin_account_id        = "678216654380"
      admin_organization_role = "bsl-cettest-logging-${var.service_name}-splunk-describe-organizations-role"
      project_code            = "01257-200"
      vault_secret_path       = format("secret/cet/splunk/%s/gray_wolf", var.service_name)
    }

    # MASTER
    "229415471955" = {
      admin_account_id        = "725799391269"
      admin_organization_role = "bsl-master-logging-${var.service_name}-splunk-describe-organizations-role"
      project_code            = "01257-000"
      vault_secret_path       = format("secret/cet/splunk/%s/red_wolf", var.service_name)
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
      "Region"              = "Global",
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

  iam_role_for_lambda_function_arn = format("arn:aws:iam::%s:role/%s-%s-%s-%s-lambda-function-role", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

  secret_name = format("%s-%s-%s-%s-secret", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)


  iam_role_for_step_function   = format("%s-%s-%s-%s-step-function-role", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  iam_role_for_lambda_function = format("%s-%s-%s-%s-lambda-function-role", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

  iam_policy_for_step_function = {
    iam_policy = {
      description = format("LSEG custom policy for %s", local.iam_role_for_step_function)
      name        = format("%s-%s-%s-%s-step-function-policy", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
      path        = "/"
      policy      = data.aws_iam_policy_document.iam_policy_for_step_function.json
    }
  }

  iam_policy_for_lambda_function = {
    iam_policy = {
      description = format("LSEG custom policy for %s", local.iam_role_for_lambda_function)
      name        = format("%s-%s-%s-%s-lambda-function-policy", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
      path        = "/"
      policy      = data.aws_iam_policy_document.iam_policy_for_lambda_function.json
    }
  }

  iam_policy_for_step_function_policy_arn   = format("arn:aws:iam::%s:policy/%s-%s-%s-%s-step-function-policy", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  iam_policy_for_lambda_function_policy_arn = format("arn:aws:iam::%s:policy/%s-%s-%s-%s-lambda-function-policy", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

  step_function_arn   = format("arn:aws:states:*:%s:stateMachine:%s-%s-%s-%s-step-function-to-orchestration-flow", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  lambda_function_arn = format("arn:aws:lambda:*:%s:function:%s-%s-%s-%s-lambda-function-to-ingest-logs", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  sqs_queue_arn       = format("arn:aws:sqs:*:%s:%s-%s-%s-%s-sqs-queue-to-manage-failover", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  sns_topic_arn       = format("arn:aws:sns:*:%s:%s-%s-%s-%s-sns-topic", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
  secret_arn          = format("arn:aws:secretsmanager:*:%s:secret:%s-%s-%s-%s-secret", data.aws_caller_identity.current.account_id, local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)

}