# Lambda 模块输出
output "users_lambda_function_name" {
  description = "Name of the Users Lambda function"
  value       = aws_lambda_function.users.function_name
}

output "users_lambda_function_arn" {
  description = "ARN of the Users Lambda function"
  value       = aws_lambda_function.users.arn
}

output "users_lambda_invoke_arn" {
  description = "Invoke ARN of the Users Lambda function"
  value       = aws_lambda_function.users.invoke_arn
}

output "products_lambda_function_name" {
  description = "Name of the Products Lambda function"
  value       = aws_lambda_function.products.function_name
}

output "products_lambda_function_arn" {
  description = "ARN of the Products Lambda function"
  value       = aws_lambda_function.products.arn
}

output "products_lambda_invoke_arn" {
  description = "Invoke ARN of the Products Lambda function"
  value       = aws_lambda_function.products.invoke_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_exec.arn
}

output "lambda_security_group_id" {
  description = "Security group ID for Lambda functions (if VPC enabled)"
  value       = var.enable_vpc_access ? aws_security_group.lambda[0].id : null
}

# CloudWatch 日志组信息
output "users_lambda_log_group" {
  description = "CloudWatch log group for Users Lambda"
  value       = aws_cloudwatch_log_group.users_lambda.name
}

output "products_lambda_log_group" {
  description = "CloudWatch log group for Products Lambda"
  value       = aws_cloudwatch_log_group.products_lambda.name
}
