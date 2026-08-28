output "node_ips" {
  description = "Public IPs (Elastic IPs)"
  value       = aws_eip.node[*].public_ip
}

output "node_private_ips" {
  description = "Private IPs for k3s agent join"
  value       = aws_instance.node[*].private_ip
}

output "node_ids" {
  description = "Instance IDs"
  value       = aws_instance.node[*].id
}
