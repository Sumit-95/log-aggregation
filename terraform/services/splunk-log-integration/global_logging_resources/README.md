## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.60.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.60.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.20.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_for_lambda_function"></a> [iam\_for\_lambda\_function](#module\_iam\_for\_lambda\_function) | git::https://bitbucket.unix.lch.com:8443/scm/ceatm/iam-assume-role.git | 4.0.0 |
| <a name="module_iam_for_step_function"></a> [iam\_for\_step\_function](#module\_iam\_for\_step\_function) | git::https://bitbucket.unix.lch.com:8443/scm/ceatm/iam-assume-role.git | 4.0.0 |
| <a name="module_secret"></a> [secret](#module\_secret) | ../../../modules/secrets_manager | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_iam_policy_document.assume_role_policy_for_step_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_policy_for_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_policy_for_step_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secret_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_regions.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |
| [vault_generic_secret.splunk_hec_token](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | n/a | `string` | `"APP-00814"` | no |
| <a name="input_cost_centre"></a> [cost\_centre](#input\_cost\_centre) | n/a | `string` | `"CC51256"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | n/a | `string` | `"gd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_for_lambda_function_policy_name"></a> [iam\_for\_lambda\_function\_policy\_name](#output\_iam\_for\_lambda\_function\_policy\_name) | List of policy name. |
| <a name="output_iam_for_lambda_function_role_name"></a> [iam\_for\_lambda\_function\_role\_name](#output\_iam\_for\_lambda\_function\_role\_name) | IAM role name. |
| <a name="output_iam_for_step_function_policy_name"></a> [iam\_for\_step\_function\_policy\_name](#output\_iam\_for\_step\_function\_policy\_name) | List of policy name. |
| <a name="output_iam_for_step_function_role_name"></a> [iam\_for\_step\_function\_role\_name](#output\_iam\_for\_step\_function\_role\_name) | IAM role name. |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Secret topic arn. |

## hcl .tfvars file format

```
application_id = "APP-00814"
cost_centre    = "CC51256"
service_name   = "gd"
```