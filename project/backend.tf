terraform {

  backend "s3" {
    region         = "ap-southeast-2"
    bucket         = "terraform-backend20231013052848766400000001"
    key            = "services/tf-workspace-ex/project.tfstate"
    dynamodb_table = "terraform_state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}

provider "aws" {
  region = var.region
}
