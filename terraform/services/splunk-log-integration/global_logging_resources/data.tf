data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "current" {}

data "aws_regions" "all" {
}

data "vault_generic_secret" "splunk_hec_token" {
  path = lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "vault_secret_path")
}

data "aws_iam_policy_document" "iam_policy_for_step_function" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "lambda:Invoke*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "states:ListStateMachines"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "states:StartExecution",
      "states:ListExecutions",
      "states:StopExecution",
      "states:DescribeStateMachineForExecution"
    ]
    resources = [local.step_function_arn]
  }
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [local.sqs_queue_arn]
  }
  statement {
    actions = [
      "sns:Publish"
    ]
    resources = [local.sns_topic_arn]
  }
}

data "aws_iam_policy_document" "iam_policy_for_lambda_function" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [local.secret_arn]
  }
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [local.sqs_queue_arn]
  }
  statement {
    sid     = "PolicyToAssumeRoleInAdminAccount"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "admin_account_id")}:role/${lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "admin_organization_role")}",
    ]
  }
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role_policy_for_step_function" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["states.amazonaws.com",
      "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_lambda_function" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secret_policy" {
  statement {
    sid    = "AllowLambdaToGetSecretValue"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.iam_role_for_lambda_function_arn]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["${local.secret_arn}*"]
  }
}
