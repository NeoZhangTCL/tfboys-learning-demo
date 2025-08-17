# 安全组模块
# API 安全组：临时放开 80/443（你也可以先只开 22/SSH 自测）
resource "aws_security_group" "api" {
  name        = "api-${var.env}"
  description = "Allow HTTP/HTTPS from internet; SSH for admin"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH（生产建议只允许你的固定IP）
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "TEMP: lock this down later"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "sg-api-${var.env}" })
}

# DB 安全组：仅允许来自 API 安全组的 5432（PostgreSQL 示例）
resource "aws_security_group" "db" {
  name        = "db-${var.env}"
  description = "Allow DB access from API SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from API SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.api.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "sg-db-${var.env}" })
}
