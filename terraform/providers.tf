terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Local state configuration by default for ease of local testing.
  # Can be upgraded to S3 backend by uncommenting and configuring below:
  # backend "s3" {
  #   bucket         = "YOUR_TF_STATE_BUCKET"
  #   key            = "f1-regulations-rag/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "YOUR_TF_LOCK_TABLE"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
