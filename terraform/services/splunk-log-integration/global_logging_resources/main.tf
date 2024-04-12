module "iam_for_step_function" {
  source                 = "git::https://bitbucket.unix.lch.com:8443/scm/ceatm/iam-assume-role.git?ref=4.0.0"
  is_iam_policy          = true
  is_iam_assume_role     = true
  is_iam_policy_attached = true
  assume_role_name       = local.iam_role_for_step_function
  iam_policies           = local.iam_policy_for_step_function
  assume_role_policies   = [local.iam_policy_for_step_function_policy_arn]
  assume_role_policy     = data.aws_iam_policy_document.assume_role_policy_for_step_function.json
  assume_role_tags       = local.common_tags
}

module "iam_for_lambda_function" {
  source                 = "git::https://bitbucket.unix.lch.com:8443/scm/ceatm/iam-assume-role.git?ref=4.0.0"
  is_iam_policy          = true
  is_iam_assume_role     = true
  is_iam_policy_attached = true
  assume_role_name       = local.iam_role_for_lambda_function
  iam_policies           = local.iam_policy_for_lambda_function
  assume_role_policies   = [local.iam_policy_for_lambda_function_policy_arn, "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  assume_role_policy     = data.aws_iam_policy_document.assume_role_policy_lambda_function.json
  assume_role_tags       = local.common_tags
}

module "secret" {
  source              = "../../../modules/secrets_manager"
  secret_name         = local.secret_name
  secret_value        = data.vault_generic_secret.splunk_hec_token.data["key"]
  secret_policy       = data.aws_iam_policy_document.secret_policy.json
  tags                = local.common_tags
  replication_regions = var.service_name == "waf" ? [] : setsubtract(data.aws_regions.all.names, ["eu-west-2"])
  depends_on = [
    module.iam_for_step_function,
    module.iam_for_lambda_function
  ]
}
