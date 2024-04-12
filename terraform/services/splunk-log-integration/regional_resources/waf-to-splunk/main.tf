module "lambda" {
  source                  = "git::https://bitbucket.unix.lch.com:8443/scm/ceatm/lambda?ref=2.1.0"
  lambda_function_name    = local.lambda_function_name
  lambda_description      = "This Lambda Function which will ingest the GuardDuty Findings"
  lambda_payload_zip_path = data.archive_file.lambda_code.output_path
  source_code_hash        = data.archive_file.lambda_code.output_base64sha256
  lambda_role_arn         = local.iam_role_for_lambda_function_arn
  lambda_handler          = "index.handler"
  lambda_run_time         = "nodejs18.x"
  lambda_memory_size      = "512"
  lambda_timeout          = "10"
  lambda_environment_variables = {
    "SPLUNK_HEC_URL"             = lookup(local.splunk_hec_url_mapping[local.environment_type], "splunk_hec_url"),
    "SPLUNK_HEC_TOKEN_PATH"      = local.splunk_hec_token_name
    "ORG_ADMIN_ACCOUNT_NUMBER"   = lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "admin_account_id")
    "ORG_ADMIN_LOGGING_STS_ROLE" = lookup(local.admin_account_mapping[data.aws_caller_identity.current.account_id], "admin_organization_role")
  }
  lambda_cw_log_group_retention = "30"
  lambda_function_arn           = false
  tags                          = local.common_tags
}

module "sqs" {
  source           = "../../../../modules/sqs"
  sqs_queue_name   = local.sqs_queue_name
  sqs_queue_policy = data.aws_iam_policy_document.sqs_queue_policy.json
  tags             = local.common_tags
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  event_source_arn = module.sqs.sqs_queue_arn
  enabled          = true
  function_name    = module.lambda.lambda_arn
  batch_size       = 1
}

module "sns" {
  source           = "git::https://bitbucket.unix.lch.com:8443/scm/ceatm/sns?ref=1.3.0"
  sns_topic_name   = local.sns_topic_name
  sns_topic_policy = data.aws_iam_policy_document.sns_topic_policy.json
  tags             = local.common_tags
}

resource "aws_sns_topic_subscription" "subscription" {
  for_each   = toset(var.email_subscription_list)
  topic_arn  = module.sns.sns_topic_arn
  protocol   = "email"
  endpoint   = each.value
  depends_on = [module.sns]
}

module "step_function" {
  source             = "../../../../modules/step_function"
  step_function_name = local.step_function_name
  role_arn           = local.iam_role_for_step_function_arn
  definition         = local.definition
  tags               = local.common_tags
  depends_on         = [module.lambda, module.sqs, module.sns]
}

module "cloudwatch_event" {
  source        = "git::https://bitbucket.unix.lch.com:8443/scm/ceatm/cloudwatch-event?ref=1.1.0"
  name          = local.cloudwatch_event_rule_name
  description   = local.cloudwatch_event_rule_description
  event_pattern = lookup(local.service_specific_vars[var.service_name], "event_pattern")
  role_arn      = local.iam_role_for_step_function_arn
  taget_arn     = module.step_function.step_function_arn
  tags          = local.common_tags
  depends_on    = [module.step_function]
}
