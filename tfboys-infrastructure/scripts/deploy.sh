#!/bin/bash
# 部署脚本

ENV=${1:-dev}
AUTO_APPROVE=${2:-false}

echo "🚀 部署到 $ENV 环境..."

# 检查环境配置文件
if [ ! -f "environments/$ENV/terraform.tfvars" ]; then
    echo "❌ 环境配置文件不存在: environments/$ENV/terraform.tfvars"
    exit 1
fi

# 初始化Terraform
terraform init

# 选择工作空间
if [ "$ENV" != "dev" ]; then
    terraform workspace select $ENV 2>/dev/null || terraform workspace new $ENV
fi

# 执行部署
if [ "$AUTO_APPROVE" = "true" ]; then
    terraform apply -var-file=environments/$ENV/terraform.tfvars -auto-approve
else
    terraform plan -var-file=environments/$ENV/terraform.tfvars
    echo "是否继续部署？ (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        terraform apply -var-file=environments/$ENV/terraform.tfvars
    else
        echo "部署取消"
        exit 1
    fi
fi

echo "✅ 部署完成！"
