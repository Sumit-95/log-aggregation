resource "aws_sqs_queue" "sqs" {
  name                      = var.sqs_queue_name
  delay_seconds             = 90
  max_message_size          = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 10
  tags                      = merge(var.tags, tomap({ "AWSResourceType" = "SQS_QUEUE" }))
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs.url
  policy    = var.sqs_queue_policy
}