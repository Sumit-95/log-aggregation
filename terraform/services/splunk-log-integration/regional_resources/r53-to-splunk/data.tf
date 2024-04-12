data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

data "aws_region" "current" {}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "./lambda_code"
  output_path = "lambda_code.zip"
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  statement {
    sid    = "AllowStepFunctionToPushMessage"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.iam_role_for_step_function_arn}"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["${local.sqs_queue_arn}"]
  }
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid    = "AllowStepFunctionToPublish"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.iam_role_for_step_function_arn}"]
    }

    actions   = ["SNS:Publish"]
    resources = ["${local.sns_topic_arn}*"]
  }
}

