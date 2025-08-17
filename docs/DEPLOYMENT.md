# 🚀 TFBoys 部署指南

## 🎯 快速开始

### 先决条件
```bash
# 必需工具
✅ Terraform >= 1.5
✅ Go >= 1.21  
✅ AWS CLI >= 2.0
✅ Git

# AWS 配置
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET  
# Default region: us-east-1
# Default output format: json
```

### ⚡ 一键部署
```bash
# 1. 克隆项目
git clone <your-repo-url>
cd tfboys

# 2. 构建后端服务
cd tfboys-backend
make build  # 构建优化后的Lambda函数

# 3. 部署基础设施  
cd ../tfboys-infrastructure
terraform init
terraform apply -var-file=environments/dev/terraform.tfvars

# 4. 获取API信息
terraform output
```

## 🏗️ 详细部署流程

### Step 1: 后端服务构建
```bash
cd tfboys-backend

# 查看可用命令
make help

# 构建所有服务 (优化版本，减少31%文件大小)
make build

# 本地测试构建
make build-local

# 运行测试  
make test

# 清理构建文件
make clean
```

**构建输出**:
```
🔨 构建用户服务...
services/users/bootstrap     # 7.6MB (优化后)
🔨 构建产品服务...  
services/products/bootstrap  # 7.6MB (优化后)
```

### Step 2: 基础设施部署

#### 使用部署脚本 (推荐)
```bash
cd tfboys-infrastructure

# 开发环境 (交互式)
./scripts/deploy.sh dev

# 开发环境 (自动批准)  
./scripts/deploy.sh dev true

# 生产环境
./scripts/deploy.sh prod
```

#### 手动部署
```bash
cd tfboys-infrastructure

# 初始化
terraform init

# 开发环境
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# 生产环境 (使用workspace)
terraform workspace new prod
terraform workspace select prod
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

### Step 3: 验证部署
```bash
# 获取部署信息
terraform output

# 示例输出:
# api_gateway_url = "https://abc123.execute-api.us-east-1.amazonaws.com/dev"
# api_key_value = "your-secret-api-key"
# db_instance_endpoint = "dev-postgres.xyz.us-east-1.rds.amazonaws.com:5432"
```

## 🧪 API测试

### 获取API信息
```bash
# 获取API网关URL
API_URL=$(terraform output -raw api_gateway_url)

# 获取API密钥  
API_KEY=$(terraform output -raw api_key_value)

# 显示测试命令
terraform output api_test_commands
```

### 测试用户API
```bash
# 获取所有用户
curl -X GET "$API_URL/users" \
  -H "x-api-key: $API_KEY"

# 创建用户
curl -X POST "$API_URL/users" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"张三","email":"zhang@example.com"}'

# 获取特定用户
curl -X GET "$API_URL/users/1" \
  -H "x-api-key: $API_KEY"
```

### 测试产品API
```bash
# 获取所有产品
curl -X GET "$API_URL/products" \
  -H "x-api-key: $API_KEY"

# 创建产品
curl -X POST "$API_URL/products" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试产品","price":99.99}'
```

## 🌍 多环境部署

### 环境配置对比
| 环境 | 实例类型 | Lambda内存 | API限制 | 数据库 |
|-----|---------|-----------|---------|-------|
| dev | t3.micro | 256MB | 50 req/s | db.t3.micro |
| staging | t3.small | 384MB | 150 req/s | db.t3.small |  
| prod | t3.medium | 512MB | 500 req/s | db.t3.medium |

### 切换环境
```bash
# 查看当前workspace
terraform workspace list

# 切换到生产环境
terraform workspace select prod

# 部署生产环境
terraform apply -var-file=environments/prod/terraform.tfvars
```

## 🔧 故障排除

### 常见问题

#### 1. Lambda上传慢 ✅ **已优化**
```bash
# 问题: 原来11MB文件上传慢
# 解决: 使用 -ldflags='-s -w' 减少到7.6MB (31%减少)

# 当前构建命令 (自动优化)
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags='-s -w' -o bootstrap main.go
```

#### 2. Terraform初始化失败
```bash
# 清除缓存重新初始化
rm -rf .terraform
terraform init
```

#### 3. API访问被拒绝
```bash
# 检查API密钥
echo $API_KEY

# 确认API网关URL
echo $API_URL

# 检查安全组配置
terraform output security_group_ids
```

#### 4. 数据库连接失败
```bash
# 检查数据库状态
aws rds describe-db-instances --region us-east-1

# 检查Lambda VPC配置  
terraform output lambda_vpc_config

# 测试数据库连接
terraform output db_connection_command
```

### 日志查看
```bash
# Lambda函数日志
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/dev-"

# API Gateway日志
aws logs describe-log-groups --log-group-name-prefix "/aws/apigateway/"

# 查看最新日志
aws logs tail "/aws/lambda/dev-users-api" --follow
```

## 🔄 CI/CD集成 (可选)

### GitHub Actions示例
```yaml
# .github/workflows/deploy.yml
name: Deploy TFBoys
on:
  push:
    branches: [main]
    
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Go
        uses: actions/setup-go@v3
        with:
          go-version: 1.21
          
      - name: Build Backend
        run: |
          cd tfboys-backend
          make build
          
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
          
      - name: Deploy Infrastructure
        run: |
          cd tfboys-infrastructure  
          terraform init
          terraform apply -var-file=environments/dev/terraform.tfvars -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## 📊 监控 & 运维

### 健康检查
```bash
# API健康检查
curl -X GET "$API_URL/users" \
  -H "x-api-key: $API_KEY" \
  -w "HTTP Status: %{http_code}, Time: %{time_total}s\n"

# 数据库健康检查  
aws rds describe-db-instances \
  --db-instance-identifier "dev-postgres" \
  --query 'DBInstances[0].DBInstanceStatus'
```

### 性能监控
```bash
# Lambda函数指标
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=dev-users-api \
  --statistics Average \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600
```

## 🗑️ 清理资源

### 完全清理 (谨慎操作)
```bash
# 销毁所有资源
cd tfboys-infrastructure
terraform destroy -var-file=environments/dev/terraform.tfvars

# 清理workspace
terraform workspace select default
terraform workspace delete dev

# 清理构建文件
cd ../tfboys-backend  
make clean
```

### 选择性清理
```bash
# 仅删除Lambda函数
terraform destroy -target=module.lambda

# 仅删除API Gateway
terraform destroy -target=module.api_gateway
```
