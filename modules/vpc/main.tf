# VPC 模块 - 网络基础设施
# 1) VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "vpc-${var.env}"
  })
}

# 2) Internet Gateway（给公有子网出网）
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "igw-${var.env}" })
}

# 3) 可用区数据源
data "aws_availability_zones" "available" {}

# 4) 公有子网（两个可用区）
resource "aws_subnet" "public" {
  for_each = {
    a = { cidr = var.public_subnet_cidrs[0], az = data.aws_availability_zones.available.names[0] }
    b = { cidr = var.public_subnet_cidrs[1], az = data.aws_availability_zones.available.names[1] }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "public-${var.env}-${each.key}"
    Tier = "public"
  })
}

# 5) 私有子网（两个可用区）
resource "aws_subnet" "private" {
  for_each = {
    a = { cidr = var.private_subnet_cidrs[0], az = data.aws_availability_zones.available.names[0] }
    b = { cidr = var.private_subnet_cidrs[1], az = data.aws_availability_zones.available.names[1] }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.common_tags, {
    Name = "private-${var.env}-${each.key}"
    Tier = "private"
  })
}

# 6) 公有路由表 + 关联（出网走 IGW）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "rt-public-${var.env}" })
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
