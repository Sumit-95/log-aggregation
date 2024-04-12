resource "aws_sfn_state_machine" "step_function" {
  name       = var.step_function_name
  role_arn   = var.role_arn
  definition = var.definition
  tags       = merge(var.tags, tomap({ "AWSResourceType" = "STEP_FUNCTION" }))
}