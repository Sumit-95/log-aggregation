output "iam_for_step_function_policy_name" {
  description = "List of policy name."
  value       = module.iam_for_step_function.policy_name
}

output "iam_for_step_function_role_name" {
  description = "IAM role name."
  value       = module.iam_for_step_function.role_name
}

output "iam_for_lambda_function_policy_name" {
  description = "List of policy name."
  value       = module.iam_for_lambda_function.policy_name
}

output "iam_for_lambda_function_role_name" {
  description = "IAM role name."
  value       = module.iam_for_lambda_function.role_name
}

output "secret_name" {
  description = "Secret topic arn."
  value       = module.secret.secret_name
}
