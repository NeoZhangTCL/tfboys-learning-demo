variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.env))
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

# RDS 数据库配置变量
variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  
  validation {
    condition = length(var.master_password) >= 8
    error_message = "Master password must be at least 8 characters long."
  }
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

# Lambda 函数配置变量
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "lambda_log_retention_days" {
  description = "Lambda CloudWatch logs retention in days"
  type        = number
  default     = 14
}

variable "enable_lambda_vpc_access" {
  description = "Enable VPC access for Lambda functions to connect to RDS"
  type        = bool
  default     = true
}

# API Gateway 配置变量
variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "api_quota_limit" {
  description = "API quota limit per day"
  type        = number
  default     = 10000
}

variable "api_rate_limit" {
  description = "API rate limit requests per second"
  type        = number
  default     = 100
}

variable "api_burst_limit" {
  description = "API burst limit"
  type        = number
  default     = 200
}


