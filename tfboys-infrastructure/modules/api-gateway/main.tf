# API Gateway 模块 - RESTful API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.env}-serverless-api"
  description = "Serverless RESTful API for ${var.env} environment"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.common_tags, {
    Name = "api-gateway-${var.env}"
    Type = "api-gateway"
  })
}

# API Gateway 部署
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    # Methods
    aws_api_gateway_method.users_get,
    aws_api_gateway_method.users_post,
    aws_api_gateway_method.users_put,
    aws_api_gateway_method.users_delete,
    aws_api_gateway_method.user_get,
    aws_api_gateway_method.user_put,
    aws_api_gateway_method.user_delete,
    aws_api_gateway_method.products_get,
    aws_api_gateway_method.products_post,
    aws_api_gateway_method.products_put,
    aws_api_gateway_method.products_delete,
    aws_api_gateway_method.product_get,
    aws_api_gateway_method.product_put,
    aws_api_gateway_method.product_delete,
    # Integrations - 确保集成也都完成
    aws_api_gateway_integration.users_lambda,
    aws_api_gateway_integration.products_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users.id,
      aws_api_gateway_resource.user_id.id,
      aws_api_gateway_resource.products.id,
      aws_api_gateway_resource.product_id.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  # 日志记录暂时禁用（需要额外的CloudWatch角色配置）
  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  #   format = jsonencode({
  #     requestId      = "$context.requestId"
  #     ip            = "$context.identity.sourceIp"
  #     caller        = "$context.identity.caller"
  #     user          = "$context.identity.user"
  #     requestTime   = "$context.requestTime"
  #     httpMethod    = "$context.httpMethod"
  #     resourcePath  = "$context.resourcePath"
  #     status        = "$context.status"
  #     protocol      = "$context.protocol"
  #     responseLength = "$context.responseLength"
  #   })
  # }

  tags = merge(var.common_tags, {
    Name = "api-stage-${var.env}"
  })
}

# CloudWatch日志组
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.env}-serverless-api"
  retention_in_days = 14

  tags = merge(var.common_tags, {
    Name = "api-gateway-logs-${var.env}"
  })
}

# API Key 用于认证
resource "aws_api_gateway_api_key" "main" {
  name = "${var.env}-api-key"
  
  tags = merge(var.common_tags, {
    Name = "api-key-${var.env}"
  })
}

# 使用计划
resource "aws_api_gateway_usage_plan" "main" {
  name = "${var.env}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = var.api_quota_limit
    period = "DAY"
  }

  throttle_settings {
    rate_limit  = var.api_rate_limit
    burst_limit = var.api_burst_limit
  }

  tags = merge(var.common_tags, {
    Name = "usage-plan-${var.env}"
  })
}

# 关联API Key到使用计划
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

# ========== Users 资源 ==========
# /users 资源
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "users"
}

# /users/{id} 资源
resource "aws_api_gateway_resource" "user_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{id}"
}

# GET /users
resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

# POST /users
resource "aws_api_gateway_method" "users_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

# PUT /users
resource "aws_api_gateway_method" "users_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "PUT"
  authorization = "NONE"
  api_key_required = true
}

# DELETE /users  
resource "aws_api_gateway_method" "users_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "DELETE"
  authorization = "NONE"
  api_key_required = true
}

# GET /users/{id}
resource "aws_api_gateway_method" "user_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

# PUT /users/{id}
resource "aws_api_gateway_method" "user_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "PUT"
  authorization = "NONE"
  api_key_required = true
}

# DELETE /users/{id}
resource "aws_api_gateway_method" "user_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "DELETE"
  authorization = "NONE"
  api_key_required = true
}

# ========== Products 资源 ==========
# /products 资源
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "products"
}

# /products/{id} 资源
resource "aws_api_gateway_resource" "product_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.products.id
  path_part   = "{id}"
}

# GET /products
resource "aws_api_gateway_method" "products_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

# POST /products
resource "aws_api_gateway_method" "products_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

# PUT /products
resource "aws_api_gateway_method" "products_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "PUT"
  authorization = "NONE"
  api_key_required = true
}

# DELETE /products
resource "aws_api_gateway_method" "products_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "DELETE"
  authorization = "NONE"
  api_key_required = true
}

# GET /products/{id}
resource "aws_api_gateway_method" "product_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.product_id.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

# PUT /products/{id}
resource "aws_api_gateway_method" "product_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.product_id.id
  http_method   = "PUT"
  authorization = "NONE"
  api_key_required = true
}

# DELETE /products/{id}
resource "aws_api_gateway_method" "product_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.product_id.id
  http_method   = "DELETE"
  authorization = "NONE"
  api_key_required = true
}

# ========== Lambda 集成 ==========
# Users Lambda 集成
resource "aws_api_gateway_integration" "users_lambda" {
  for_each = toset([
    "users_get", "users_post", "users_put", "users_delete",
    "user_get", "user_put", "user_delete"
  ])

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = contains(["user_get", "user_put", "user_delete"], each.key) ? aws_api_gateway_resource.user_id.id : aws_api_gateway_resource.users.id
  
  http_method = local.method_mapping[each.key]
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.users_lambda_invoke_arn
}

# Products Lambda 集成
resource "aws_api_gateway_integration" "products_lambda" {
  for_each = toset([
    "products_get", "products_post", "products_put", "products_delete",
    "product_get", "product_put", "product_delete"
  ])

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = contains(["product_get", "product_put", "product_delete"], each.key) ? aws_api_gateway_resource.product_id.id : aws_api_gateway_resource.products.id
  
  http_method = local.method_mapping[each.key]
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.products_lambda_invoke_arn
}

# 本地变量用于方法映射
locals {
  method_mapping = {
    users_get      = "GET"
    users_post     = "POST"
    users_put      = "PUT"
    users_delete   = "DELETE"
    user_get       = "GET"
    user_put       = "PUT"
    user_delete    = "DELETE"
    products_get   = "GET"
    products_post  = "POST"
    products_put   = "PUT"
    products_delete = "DELETE"
    product_get    = "GET"
    product_put    = "PUT"
    product_delete = "DELETE"
  }
}
