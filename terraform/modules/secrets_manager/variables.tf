variable "secret_name" {
  description = "Secret name."
  type        = string
}

variable "secret_policy" {
  description = "Secret policy."
  type        = string
}

variable "tags" {
  description = "Tags to apply to secret."
  type        = map(string)
}

variable "secret_value" {
  description = "The token for the splunk endpoint"
  type        = string
  sensitive   = true
}

variable "replication_regions" {
  description = "list of regions where the secret should be replicated to"
  default     = []
}