variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "project_name" {
  description = "Resource name prefix"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR allowed to reach SSH and the k3s API server"
  type        = string
  default     = "0.0.0.0/0"
}
