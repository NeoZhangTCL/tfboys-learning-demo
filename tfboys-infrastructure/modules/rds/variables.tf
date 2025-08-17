# RDS 模块变量
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID for database access"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# 数据库配置变量
variable "postgres_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.14"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"  # 免费层
  
  validation {
    condition = can(regex("^db\\.(t3|t4|m5|m6|r5|r6)", var.instance_class))
    error_message = "Instance class must be a valid RDS instance type."
  }
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
  
  validation {
    condition = var.allocated_storage >= 20 && var.allocated_storage <= 1000
    error_message = "Allocated storage must be between 20 and 1000 GB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for auto scaling"
  type        = number
  default     = 100
}

# 数据库名称和认证
variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.master_username))
    error_message = "Master username must start with a letter and contain only letters, numbers, and underscores."
  }
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

# 备份和维护配置
variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

# 安全和生命周期配置
variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false  # dev环境可以设为false，prod建议设为true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true   # dev环境可以设为true，prod建议设为false
}
