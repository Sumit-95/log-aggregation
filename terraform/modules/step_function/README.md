## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sfn_state_machine.step_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_definition"></a> [definition](#input\_definition) | Amazon states language definition for state machine. | `any` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM role for the step function. | `string` | n/a | yes |
| <a name="input_step_function_name"></a> [step\_function\_name](#input\_step\_function\_name) | Step function name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to step function. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_step_function_arn"></a> [step\_function\_arn](#output\_step\_function\_arn) | Step function arn. |
| <a name="output_step_function_name"></a> [step\_function\_name](#output\_step\_function\_name) | Step function name. |
