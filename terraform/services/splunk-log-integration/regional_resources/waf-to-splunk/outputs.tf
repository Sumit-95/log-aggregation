output "cloudwatch_event_rule_name" {
  description = "Cloudwatch event rule name."
  value       = module.cloudwatch_event.event_id
}

output "step_function_name" {
  description = "Step function name."
  value       = module.step_function.step_function_name
}

output "lambda_function_name" {
  description = "Lambda function name."
  value       = module.lambda.lambda_function_name
}

output "sqs_queue_name" {
  description = "SQS queue name."
  value       = module.sqs.sqs_queue_name
}

output "sns_topic_arn" {
  description = "SNS topic arn."
  value       = module.sns.sns_topic_arn
}

