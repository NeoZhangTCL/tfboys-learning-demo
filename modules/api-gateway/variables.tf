# API Gateway 模块变量
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# API限制配置
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

# Lambda函数调用ARN
variable "users_lambda_invoke_arn" {
  description = "Users Lambda function invoke ARN"
  type        = string
}

variable "products_lambda_invoke_arn" {
  description = "Products Lambda function invoke ARN"
  type        = string
}
