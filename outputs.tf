output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "api_security_group_id" {
  value = aws_security_group.api.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

# EC2 和密钥对相关输出
output "api_server_public_ip" {
  value       = aws_instance.api_server.public_ip
  description = "Public IP address of the API server instance"
}

output "key_pair_name" {
  value       = aws_key_pair.main.key_name
  description = "Name of the created key pair"
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the private key file"
}

output "ssh_connection_command" {
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.api_server.public_ip}"
  description = "SSH command to connect to the EC2 instance"
}