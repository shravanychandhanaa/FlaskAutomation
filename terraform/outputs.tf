# Output the public IP address of the deployed EC2 instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

# Output the public DNS name of the deployed EC2 instance
output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

# Output the Security Group ID
output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.app_security_group.id
}
