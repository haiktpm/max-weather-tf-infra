provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.5.0"
    }
  }
}
