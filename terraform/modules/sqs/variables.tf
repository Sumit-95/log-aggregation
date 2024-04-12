variable "sqs_queue_name" {
  description = "SQS queue name."
  type        = string
}

variable "sqs_queue_policy" {
  description = "SQS queue policy."
  type        = string
}

variable "tags" {
  description = "Tags to apply to SQS queue."
  type        = map(string)
}