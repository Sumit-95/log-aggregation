output "sqs_queue_name" {
  description = "SQS queue name."
  value       = aws_sqs_queue.sqs.name
}

output "sqs_queue_arn" {
  description = "SQS queue arn."
  value       = aws_sqs_queue.sqs.arn
}

output "sqs_queue_url" {
  description = "SQS queue url."
  value       = aws_sqs_queue.sqs.url
}