# EC2 模块输出
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.api_server.id
}

output "api_server_public_ip" {
  description = "Public IP address of the API server instance"
  value       = aws_instance.api_server.public_ip
}

output "api_server_private_ip" {
  description = "Private IP address of the API server instance"
  value       = aws_instance.api_server.private_ip
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.main.key_name
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.api_server.public_ip}"
}
