# Lambda 模块 - Go 函数
# IAM 角色用于 Lambda 执行
resource "aws_iam_role" "lambda_exec" {
  name = "${var.env}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "lambda-exec-role-${var.env}"
  })
}

# Lambda 基础执行策略
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# VPC 访问策略（如果需要访问 RDS）
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = var.enable_vpc_access ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# Lambda 安全组（如果在 VPC 中）
resource "aws_security_group" "lambda" {
  count       = var.enable_vpc_access ? 1 : 0
  name        = "${var.env}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  # 出站规则：HTTPS（用于AWS API调用）
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 出站规则：HTTP（用于外部API调用）  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 出站规则：PostgreSQL（用于RDS连接）
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.common_tags, {
    Name = "lambda-sg-${var.env}"
  })
}

# 构建 Go Lambda 函数
resource "null_resource" "build_users_lambda" {
  triggers = {
    code_hash = filemd5("${var.source_code_path}/users/main.go")
    mod_hash  = filemd5("${var.root_dir}/go.mod")
  }

  provisioner "local-exec" {
    working_dir = "${var.source_code_path}/users"
    command     = var.build_command
  }
}

resource "null_resource" "build_products_lambda" {
  triggers = {
    code_hash = filemd5("${var.source_code_path}/products/main.go")
    mod_hash  = filemd5("${var.root_dir}/go.mod")
  }

  provisioner "local-exec" {
    working_dir = "${var.source_code_path}/products"
    command     = var.build_command
  }
}

# 创建部署包
data "archive_file" "users_lambda" {
  depends_on  = [null_resource.build_users_lambda]
  type        = "zip"
  source_file = "${var.source_code_path}/users/bootstrap"
  output_path = "${path.module}/users-lambda.zip"
}

data "archive_file" "products_lambda" {
  depends_on  = [null_resource.build_products_lambda]
  type        = "zip"
  source_file = "${var.source_code_path}/products/bootstrap"
  output_path = "${path.module}/products-lambda.zip"
}

# Users Lambda 函数
resource "aws_lambda_function" "users" {
  depends_on    = [null_resource.build_users_lambda]
  filename      = data.archive_file.users_lambda.output_path
  function_name = "${var.env}-users-api"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  source_code_hash = data.archive_file.users_lambda.output_base64sha256

  # VPC 配置（如果需要）
  dynamic "vpc_config" {
    for_each = var.enable_vpc_access ? [1] : []
    content {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = [aws_security_group.lambda[0].id]
    }
  }

  # 环境变量
  environment {
    variables = merge(var.lambda_environment_variables, {
      ENV = var.env
    })
  }

  tags = merge(var.common_tags, {
    Name = "users-lambda-${var.env}"
    Type = "lambda-function"
  })
}

# Products Lambda 函数
resource "aws_lambda_function" "products" {
  depends_on    = [null_resource.build_products_lambda]
  filename      = data.archive_file.products_lambda.output_path
  function_name = "${var.env}-products-api"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  source_code_hash = data.archive_file.products_lambda.output_base64sha256

  # VPC 配置（如果需要）
  dynamic "vpc_config" {
    for_each = var.enable_vpc_access ? [1] : []
    content {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = [aws_security_group.lambda[0].id]
    }
  }

  # 环境变量
  environment {
    variables = merge(var.lambda_environment_variables, {
      ENV = var.env
    })
  }

  tags = merge(var.common_tags, {
    Name = "products-lambda-${var.env}"
    Type = "lambda-function"
  })
}

# CloudWatch 日志组
resource "aws_cloudwatch_log_group" "users_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.users.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "users-lambda-logs-${var.env}"
  })
}

resource "aws_cloudwatch_log_group" "products_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.products.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "products-lambda-logs-${var.env}"
  })
}

# Lambda 权限 - 允许 API Gateway 调用
resource "aws_lambda_permission" "users_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_lambda_permission" "products_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
