# 主配置文件 - 组装所有模块

# VPC 模块 - 网络基础设施
module "vpc" {
  source = "./modules/vpc"

  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  common_tags          = local.common_tags
}

# Security 模块 - 安全组
module "security" {
  source = "./modules/security"

  env         = var.env
  vpc_id      = module.vpc.vpc_id
  common_tags = local.common_tags
}

# EC2 模块 - 计算实例和密钥
module "ec2" {
  source = "./modules/ec2"

  env                   = var.env
  public_subnet_id      = module.vpc.public_subnets["a"].id
  api_security_group_id = module.security.api_security_group_id
  common_tags           = local.common_tags
}

# RDS 模块 - PostgreSQL 数据库
module "rds" {
  source = "./modules/rds"

  env                   = var.env
  private_subnet_ids    = module.vpc.private_subnet_ids
  db_security_group_id  = module.security.db_security_group_id
  common_tags           = local.common_tags

  # 数据库配置
  database_name    = var.database_name
  master_username  = var.master_username
  master_password  = var.master_password
  instance_class   = var.rds_instance_class
}

# Lambda 模块 - Go 无服务器函数
module "lambda" {
  source = "./modules/lambda"

  env         = var.env
  common_tags = local.common_tags

  # Lambda 配置
  lambda_timeout      = var.lambda_timeout
  lambda_memory_size  = var.lambda_memory_size
  log_retention_days  = var.lambda_log_retention_days

  # 源代码路径配置
  source_code_path = "./lambda-code/api"

  # VPC 配置（启用以连接 RDS）
  enable_vpc_access   = var.enable_lambda_vpc_access
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = var.vpc_cidr
  private_subnet_ids  = module.vpc.private_subnet_ids

  # 环境变量
  lambda_environment_variables = {
    DB_HOST     = module.rds.db_instance_address
    DB_PORT     = tostring(module.rds.db_instance_port)
    DB_NAME     = module.rds.database_name
    DB_USER     = var.master_username
    DB_PASSWORD = var.master_password  # 生产环境应使用 Secrets Manager
  }

  # API Gateway 执行 ARN（循环依赖，先用占位符）
  api_gateway_execution_arn = module.api_gateway.rest_api_id != "" ? "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${module.api_gateway.rest_api_id}" : ""
}

# API Gateway 模块 - RESTful API
module "api_gateway" {
  source = "./modules/api-gateway"

  env         = var.env
  stage_name  = var.api_stage_name
  common_tags = local.common_tags

  # API 限制配置
  api_quota_limit = var.api_quota_limit
  api_rate_limit  = var.api_rate_limit
  api_burst_limit = var.api_burst_limit

  # Lambda 集成
  users_lambda_invoke_arn    = module.lambda.users_lambda_invoke_arn
  products_lambda_invoke_arn = module.lambda.products_lambda_invoke_arn
}

# 数据源
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
