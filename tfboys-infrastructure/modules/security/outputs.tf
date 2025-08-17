# 安全组模块输出
output "api_security_group_id" {
  description = "ID of the API security group"
  value       = aws_security_group.api.id
}

output "db_security_group_id" {
  description = "ID of the DB security group"
  value       = aws_security_group.db.id
}

output "api_security_group" {
  description = "Full API security group resource"
  value       = aws_security_group.api
}

output "db_security_group" {
  description = "Full DB security group resource"
  value       = aws_security_group.db
}
