terraform {
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.60.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20.0"
    }
  }
}