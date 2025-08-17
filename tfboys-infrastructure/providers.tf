provider "aws" {
  region = var.aws_region
}

# 统一打标签，便于账单与资源筛选
locals {
  common_tags = {
    Project = "tfboys-learning-demo"
    Owner   = "infra-training"
    Env     = var.env
  }
}