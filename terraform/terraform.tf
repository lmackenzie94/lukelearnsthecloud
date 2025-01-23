terraform {
  cloud {
    organization = "lukes-org"
    workspaces {
      name = "lukelearnsthecloud"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}