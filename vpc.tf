# 1) VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "vpc-${var.env}"
  })
}

# 2) Internet Gateway（给公有子网出网）
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "igw-${var.env}" })
}

# 3) 公有子网（两个可用区）
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  for_each = {
    a = { cidr = var.public_subnet_cidrs[0], az = data.aws_availability_zones.available.names[0] }
    b = { cidr = var.public_subnet_cidrs[1], az = data.aws_availability_zones.available.names[1] }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "public-${var.env}-${each.key}"
    Tier = "public"
  })
}

# 4) 私有子网（两个可用区）
resource "aws_subnet" "private" {
  for_each = {
    a = { cidr = var.private_subnet_cidrs[0], az = data.aws_availability_zones.available.names[0] }
    b = { cidr = var.private_subnet_cidrs[1], az = data.aws_availability_zones.available.names[1] }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = "private-${var.env}-${each.key}"
    Tier = "private"
  })
}

# 5) 公有路由表 + 关联（出网走 IGW）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "rt-public-${var.env}" })
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# 6) 安全组
# API 安全组：临时放开 80/443（你也可以先只开 22/SSH 自测）
resource "aws_security_group" "api" {
  name        = "api-${var.env}"
  description = "Allow HTTP/HTTPS from internet; SSH for admin"
  vpc_id      = aws_vpc.main.id

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

  tags = merge(local.common_tags, { Name = "sg-api-${var.env}" })
}

# DB 安全组：仅允许来自 API 安全组的 5432（PostgreSQL 示例）
resource "aws_security_group" "db" {
  name        = "db-${var.env}"
  description = "Allow DB access from API SG"
  vpc_id      = aws_vpc.main.id

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

  tags = merge(local.common_tags, { Name = "sg-db-${var.env}" })
}