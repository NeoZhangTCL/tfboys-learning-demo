# API Gateway 模块输出
output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.main.stage_name}"
}

output "api_key_id" {
  description = "API Key ID"
  value       = aws_api_gateway_api_key.main.id
}

output "api_key_value" {
  description = "API Key value"
  value       = aws_api_gateway_api_key.main.value
  sensitive   = true
}

output "stage_name" {
  description = "API Gateway stage name"
  value       = aws_api_gateway_stage.main.stage_name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.api_gateway.name
}

# API端点信息
output "api_endpoints" {
  description = "Available API endpoints"
  value = {
    users = {
      list_users   = "GET /users"
      create_user  = "POST /users" 
      get_user     = "GET /users/{id}"
      update_user  = "PUT /users/{id}"
      delete_user  = "DELETE /users/{id}"
    }
    products = {
      list_products   = "GET /products"
      create_product  = "POST /products"
      get_product     = "GET /products/{id}"
      update_product  = "PUT /products/{id}"
      delete_product  = "DELETE /products/{id}"
    }
  }
}

# 数据源
data "aws_region" "current" {}
