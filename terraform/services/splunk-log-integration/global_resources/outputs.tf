output "iam_for_describe_organizations_policy_name" {
  description = "List of policy name."
  value       = module.iam_for_describe_organizations.policy_name
}

output "iam_for_describe_organizations_role_name" {
  description = "IAM role name."
  value       = module.iam_for_describe_organizations.role_name
}