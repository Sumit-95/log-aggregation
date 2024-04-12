variable "cost_centre" {
  default = "CC51256"
}

variable "application_id" {
  default = "APP-00814"
}

variable "email_subscription_list" {
  default = ["CloudAWSDeadpoolDL@lseg.com", "CloudOpsDL@lseg.com", "CyberSecurity_SecurityOperations_CTD@lseg.com"]
  type    = list(any)
}

variable "splunk_hec_url" {
  default = "https://http-inputs-greywolf.splunkcloud.com:443/services/collector"
}

variable "service_name" {
  default = "gd"
}