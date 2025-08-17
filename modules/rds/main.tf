# RDS 模块 - PostgreSQL 数据库
# 1. RDS 子网组（使用私有子网）
resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "db-subnet-group-${var.env}"
  })
}

# 2. RDS 参数组（可选配置优化）
resource "aws_db_parameter_group" "postgres" {
  family = "postgres15"
  name   = "${var.env}-postgres-params"

  # PostgreSQL 优化参数
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = merge(var.common_tags, {
    Name = "postgres-params-${var.env}"
  })
}

# 3. RDS 实例
resource "aws_db_instance" "postgres" {
  identifier = "${var.env}-postgres-db"

  # 数据库配置
  engine                = "postgres"
  engine_version        = var.postgres_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # 数据库名称和认证
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  # 网络配置
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false  # 确保数据库不公开访问

  # 参数组和选项组
  parameter_group_name = aws_db_parameter_group.postgres.name

  # 备份配置
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  # 监控和日志
  monitoring_interval = 0  # 开发环境禁用监控，生产环境可启用
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled = false  # 开发环境禁用，生产环境可启用

  # 删除保护（生产环境建议启用）
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${var.env}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = merge(var.common_tags, {
    Name = "postgres-db-${var.env}"
    Type = "database"
  })

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password  # 避免密码变更时重建数据库
    ]
  }
}
