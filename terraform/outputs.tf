output "node_ips" {
  description = "Public IPs of the three nodes (index 0 = k3s server)"
  value       = module.instances.node_ips
}

output "node_private_ips" {
  description = "Private IPs used for k3s agent join"
  value       = module.instances.node_private_ips
}

output "node_ids" {
  description = "EC2 instance IDs"
  value       = module.instances.node_ids
}

output "ssh_commands" {
  description = "Ready-to-use SSH commands"
  value       = [for ip in module.instances.node_ips : "ssh ubuntu@${ip}"]
}
