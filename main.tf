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
