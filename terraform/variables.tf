variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "project_name" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "anoos"
}

variable "instance_type" {
  description = "EC2 instance type for all three nodes"
  type        = string
  default     = "m6i.xlarge"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
}
