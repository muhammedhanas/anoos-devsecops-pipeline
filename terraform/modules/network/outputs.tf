output "subnet_id" {
  description = "Subnet ID for the nodes"
  value       = aws_subnet.main.id
}

output "sg_id" {
  description = "Security group ID for the nodes"
  value       = aws_security_group.nodes.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
