output "step_function_name" {
  description = "Step function name."
  value       = aws_sfn_state_machine.step_function.name
}

output "step_function_arn" {
  description = "Step function arn."
  value       = aws_sfn_state_machine.step_function.arn
}