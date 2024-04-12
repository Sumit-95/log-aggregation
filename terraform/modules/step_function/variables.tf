variable "step_function_name" {
  description = "Step function name."
  type        = string
}

variable "role_arn" {
  description = "IAM role for the step function."
  type        = string
}

variable "definition" {
  description = "Amazon states language definition for state machine."
}

variable "tags" {
  description = "Tags to apply to step function."
  type        = map(string)
}