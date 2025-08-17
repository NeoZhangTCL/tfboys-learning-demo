# EC2 模块变量
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[tm][2-9]\\.", var.instance_type))
    error_message = "Instance type must be a valid t2/t3/t4/m5/m6 family instance type."
  }
}

variable "public_subnet_id" {
  description = "ID of the public subnet where EC2 instance will be created"
  type        = string
}

variable "api_security_group_id" {
  description = "ID of the API security group to attach to the instance"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
