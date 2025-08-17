# Lambda 模块变量
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Lambda 函数配置
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
  
  validation {
    condition = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 MB and 10240 MB."
  }
}

variable "lambda_environment_variables" {
  description = "Environment variables for Lambda functions"
  type        = map(string)
  default     = {}
}

# 源代码路径
variable "source_code_path" {
  description = "Path to the Go source code (relative to project root)"
  type        = string
}

# Go 构建命令
variable "build_command" {
  description = "Command to build Go Lambda function"
  type        = string
  default     = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap main.go"
}

# VPC 配置
variable "enable_vpc_access" {
  description = "Enable VPC access for Lambda functions"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for Lambda functions"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda functions"
  type        = list(string)
  default     = []
}

# API Gateway 配置
variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  type        = string
}

# 日志配置
variable "log_retention_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 14
  
  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention value."
  }
}
