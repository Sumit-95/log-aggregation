module "iam_for_describe_organizations" {
  source                 = "git::https://bitbucket.unix.lch.com:8443/scm/ceatm/iam-assume-role.git?ref=4.0.0"
  is_iam_policy          = false
  is_iam_assume_role     = true
  is_iam_policy_attached = false
  assume_role_name       = local.iam_role_for_describe_organizations
  assume_role_policies   = local.iam_role_for_describe_organizations_arn
  assume_role_policy     = data.aws_iam_policy_document.describe_organizations_policy.json
  assume_role_tags       = local.common_tags
}