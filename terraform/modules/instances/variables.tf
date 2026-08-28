variable "project_name" {
  description = "Resource name prefix"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch nodes into"
  type        = string
}

variable "sg_id" {
  description = "Security group for the nodes"
  type        = string
}

variable "node_count" {
  description = "Number of nodes (1 server + agents)"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m6i.xlarge"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 100
}
