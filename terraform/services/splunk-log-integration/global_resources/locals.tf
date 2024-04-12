locals {
  logging_account_mapping = {
    # CETDEV
    "805097478809" = {
      logging_account_id   = "668764830176"
      logging_account_name = "AWS-BSL-LOGGING-CETDEV"
      environment_type     = "CETDEV"
      project_code         = "01257-200"
    }

    # CETTEST
    "678216654380" = {
      logging_account_id   = "178111371884"
      logging_account_name = "AWS-BSL-LOGGING-CETTEST"
      environment_type     = "CETTEST"
      project_code         = "01257-200"
    }

    # MASTER
    "725799391269" = {
      logging_account_id   = "229415471955"
      logging_account_name = "AWS-BSL-LOGGING-PROD"
      environment_type     = "MASTER"
      project_code         = "01257-000"
    }
  }

  common_tags = tomap(
    {
      "ApplicationName"     = "splunk-ingestion-service",
      "ApplicationID"       = var.application_id,
      "CostCentre"          = var.cost_centre,
      "ManagedBy"           = "CET",
      "ProjectCode"         = lookup(local.logging_account_mapping[data.aws_caller_identity.current.account_id], "project_code"),
      "Automation"          = "N/A",
      "Environment"         = upper(local.environment_type),
      "Owner"               = "CloudEngineering@lseg.com",
      "Region"              = "Global",
      "Reason"              = "splunk-ingestion-service",
      "mnd-applicationid"   = lower(var.application_id),
      "mnd-applicationname" = "splunk-ingestion-service",
      "mnd-owner"           = "cloudopsdl@lseg.com",
      "mnd-supportgroup"    = "bsl cloud ops",
      "mnd-projectcode"     = lookup(local.logging_account_mapping[data.aws_caller_identity.current.account_id], "project_code"),
      "mnd-costcentre"      = "cc51256",
      "mnd-envtype"         = lower(local.environment_type),
      "mnd-envsubtype"      = "na",
      "opt-managedby"       = "cet"
    }
  )

  iam_role_for_describe_organizations_arn = [
    "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess"
  ]

  aws_business_entitiy = lower(element(split("-", lookup(local.logging_account_mapping[data.aws_caller_identity.current.account_id], "logging_account_name")), 1))
  aws_account          = lower(element(split("-", lookup(local.logging_account_mapping[data.aws_caller_identity.current.account_id], "logging_account_name")), 2))
  environment_type     = lower(lookup(local.logging_account_mapping[data.aws_caller_identity.current.account_id], "environment_type"))
  project_name         = "${var.service_name}-splunk"

  iam_role_for_describe_organizations = format("%s-%s-%s-%s-describe-organizations-role", local.aws_business_entitiy, local.environment_type, local.aws_account, local.project_name)
}