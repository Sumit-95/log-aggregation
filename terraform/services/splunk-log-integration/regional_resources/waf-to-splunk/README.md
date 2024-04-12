## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.60.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_event"></a> [cloudwatch\_event](#module\_cloudwatch\_event) | git::https://bitbucket.unix.lch.com:8443/scm/ceatm/cloudwatch-event | 1.1.0 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | git::https://bitbucket.unix.lch.com:8443/scm/ceatm/lambda | 2.1.0 |
| <a name="module_sns"></a> [sns](#module\_sns) | git::https://bitbucket.unix.lch.com:8443/scm/ceatm/sns | 1.3.0 |
| <a name="module_sqs"></a> [sqs](#module\_sqs) | ../../../../modules/sqs | n/a |
| <a name="module_step_function"></a> [step\_function](#module\_step\_function) | ../../../../modules/step_function | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_event_source_mapping.lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_sns_topic_subscription.subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.lambda_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_iam_policy_document.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | n/a | `string` | `"APP-00814"` | no |
| <a name="input_cost_centre"></a> [cost\_centre](#input\_cost\_centre) | n/a | `string` | `"CC51256"` | no |
| <a name="input_email_subscription_list"></a> [email\_subscription\_list](#input\_email\_subscription\_list) | n/a | `list(any)` | <pre>[<br>  "CloudAWSDeadpoolDL@abcd.com",<br>  "CloudOpsDL@abcd.com",<br>  "CyberSecurity_SecurityOperations_CTD@abcd.com"<br>]</pre> | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | n/a | `string` | `"gd"` | no |
| <a name="input_splunk_hec_url"></a> [splunk\_hec\_url](#input\_splunk\_hec\_url) | n/a | `string` | `"https://http-inputs-greywolf.splunkcloud.com:443/services/collector"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_name"></a> [cloudwatch\_event\_rule\_name](#output\_cloudwatch\_event\_rule\_name) | Cloudwatch event rule name. |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Lambda function name. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS topic arn. |
| <a name="output_sqs_queue_name"></a> [sqs\_queue\_name](#output\_sqs\_queue\_name) | SQS queue name. |
| <a name="output_step_function_name"></a> [step\_function\_name](#output\_step\_function\_name) | Step function name. |

## hcl .tfvars file format

```
application_id = "APP-00814"
cost_centre    = "CC51256"
email_subscription_list = [
  "CloudAWSDeadpoolDL@abcd.com",
  "CloudOpsDL@abcd.com",
  "CyberSecurity_SecurityOperations_CTD@abcd.com"
]
service_name   = "gd"
splunk_hec_url = "https://http-inputs-greywolf.splunkcloud.com:443/services/collector"
```