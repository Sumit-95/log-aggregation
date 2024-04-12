data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "describe_organizations_policy" {
  statement {
    sid = "PolicyToAssumeAdminRole"

    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${lookup(local.logging_account_mapping[data.aws_caller_identity.current.account_id], "logging_account_id")}:root"]
    }
  }
}