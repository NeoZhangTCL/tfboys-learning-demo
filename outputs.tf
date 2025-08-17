# 根目录输出 - 调用各模块的输出

# VPC 相关输出
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# 安全组相关输出
output "api_security_group_id" {
  description = "ID of the API security group"
  value       = module.security.api_security_group_id
}

output "db_security_group_id" {
  description = "ID of the DB security group"
  value       = module.security.db_security_group_id
}

# EC2 和密钥对相关输出
output "api_server_public_ip" {
  description = "Public IP address of the API server instance"
  value       = module.ec2.api_server_public_ip
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = module.ec2.key_pair_name
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = module.ec2.private_key_path
}

output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = module.ec2.ssh_connection_command
}

# RDS 相关输出
output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "database_name" {
  description = "Name of the database"
  value       = module.rds.database_name
}

output "db_connection_command" {
  description = "Database connection command from EC2"
  value       = "psql -h ${module.rds.db_instance_address} -p ${module.rds.db_instance_port} -U ${module.rds.master_username} -d ${module.rds.database_name}"
  sensitive   = true
}

# API Gateway 相关输出
output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "api_key_value" {
  description = "API Key for authentication"
  value       = module.api_gateway.api_key_value
  sensitive   = true
}

output "api_endpoints" {
  description = "Available API endpoints"
  value       = module.api_gateway.api_endpoints
}

# Lambda 相关输出  
output "users_lambda_function_name" {
  description = "Name of the Users Lambda function"
  value       = module.lambda.users_lambda_function_name
}

output "products_lambda_function_name" {
  description = "Name of the Products Lambda function"
  value       = module.lambda.products_lambda_function_name
}

# 测试命令输出
output "api_test_commands" {
  description = "Test commands for the API"
  value = {
    get_users = "curl -H \"X-API-Key: $(terraform output -raw api_key_value)\" ${module.api_gateway.api_gateway_url}/users"
    get_products = "curl -H \"X-API-Key: $(terraform output -raw api_key_value)\" ${module.api_gateway.api_gateway_url}/products"
    create_user = "curl -X POST -H \"X-API-Key: $(terraform output -raw api_key_value)\" -H \"Content-Type: application/json\" -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\"}' ${module.api_gateway.api_gateway_url}/users"
  }
}