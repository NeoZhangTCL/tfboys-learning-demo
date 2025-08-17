# VPC 模块输出
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "public_subnets" {
  description = "Map of public subnets with their details"
  value       = aws_subnet.public
}

output "private_subnets" {
  description = "Map of private subnets with their details"
  value       = aws_subnet.private
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}
