locals {
  tags = {
    "TerraformProject"  = "https://github.com/amieldelatorre/discord_notifier",
    "Project"           = "discord_notifier"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.40"
    }
    local = {
      source = "hashicorp/local"
      version = ">=2.5"
    }
  }
}


provider "aws" {
  region  = var.region
  profile = var.aws_profile
  
  default_tags {
    tags = local.tags
  }
}

provider "local" {}