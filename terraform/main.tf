# ANOOS DevSecOps Pipeline - Terraform layer
# 3x EC2 instances running self-managed k3s. No EKS, no managed control plane.

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}

module "network" {
  source       = "./modules/network"
  region       = var.region
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
}

module "instances" {
  source        = "./modules/instances"
  project_name  = var.project_name
  subnet_id     = module.network.subnet_id
  sg_id         = module.network.sg_id
  node_count    = 3
  instance_type = var.instance_type
  key_name      = var.key_name
}
