# TFBoys - AWS基础设施Terraform项目

## 项目概述

这是一个用于学习和演示的模块化Terraform项目，用于在AWS上部署完整的三层应用架构。项目名称"tfboys"来自于Terraform Boys的缩写，是一个基础设施即代码(IaC)的实践项目。

## 架构组件

### 🌐 网络层 (VPC模块)

- **VPC**: 创建隔离的虚拟私有云
- **公有子网**: 用于部署面向互联网的资源（如EC2实例）
- **私有子网**: 用于部署数据库等后端资源
- **Internet Gateway**: 提供互联网访问
- **路由表**: 配置网络路由规则

### 🔒 安全层 (Security模块)

- **API安全组**: 允许HTTP(80)、HTTPS(443)和SSH(22)访问
- **数据库安全组**: 只允许来自API安全组的PostgreSQL(5432)连接

### 💻 计算层 (EC2模块)

- **EC2实例**: Amazon Linux 2实例作为应用服务器
- **密钥对管理**: 自动生成SSH密钥对用于安全访问

### 🗄️ 数据层 (RDS模块)

- **PostgreSQL数据库**: 使用RDS托管的PostgreSQL 15
- **子网组**: 跨可用区部署以实现高可用性
- **参数组**: 针对PostgreSQL的性能优化配置
- **备份策略**: 7天备份保留期和维护窗口配置

## 项目结构

```text
tfboys/
├── main.tf                    # 主配置文件，组装所有模块
├── providers.tf               # AWS提供商配置和通用标签
├── variables.tf               # 根级变量定义
├── outputs.tf                 # 输出配置
├── versions.tf                # Terraform和提供商版本约束
├── envs/                      # 环境特定配置
│   ├── dev.tfvars            # 开发环境变量
│   └── prod.tfvars           # 生产环境变量
├── keys/                      # SSH密钥存储目录
└── modules/                   # 可重用模块
    ├── vpc/                  # VPC网络模块
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/             # 安全组模块
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                  # EC2计算模块
    │   ├── main.tf
    │   ├── keypair.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds/                  # RDS数据库模块
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 环境配置

### 开发环境 (dev)

- VPC CIDR: `10.10.0.0/16`
- 公有子网: `10.10.1.0/24`, `10.10.2.0/24`
- 私有子网: `10.10.101.0/24`, `10.10.102.0/24`
- RDS实例类型: `db.t3.micro`

### 生产环境 (prod)

- VPC CIDR: `10.20.0.0/16`
- 公有子网: `10.20.1.0/24`, `10.20.2.0/24`
- 私有子网: `10.20.101.0/24`, `10.20.102.0/24`
- RDS实例类型: `db.t3.small`

## 快速开始

### 1. 先决条件

```bash
# 安装Terraform (>= 1.6.0)
brew install terraform  # macOS
# 或从官网下载: https://developer.hashicorp.com/terraform/downloads

# 配置AWS凭据
aws configure
# 或设置环境变量
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

### 2. 部署步骤

#### 开发环境部署

```bash
# 克隆项目
git clone <repository-url>
cd tfboys

# 初始化Terraform
terraform init

# 验证配置
terraform validate

# 查看执行计划
terraform plan -var-file="envs/dev.tfvars"

# 部署基础设施
terraform apply -var-file="envs/dev.tfvars"
```

#### 生产环境部署

```bash
# 使用生产环境配置
terraform plan -var-file="envs/prod.tfvars"
terraform apply -var-file="envs/prod.tfvars"
```

### 3. 访问资源

部署完成后，Terraform会输出以下信息：

- EC2实例的公网IP地址
- SSH连接命令
- 数据库连接信息

```bash
# SSH连接到EC2实例
ssh -i keys/tfboys-keypair-dev.pem ec2-user@<public-ip>

# 从EC2连接到数据库
psql -h <db-endpoint> -p 5432 -U dbadmin -d appdb
```

## 技术特性

### 🏗️ 模块化设计

- 每个模块职责单一，便于维护和重用
- 清晰的输入输出接口定义
- 支持多环境部署

### 🔐 安全最佳实践

- 数据库部署在私有子网中
- 最小权限原则的安全组配置
- 敏感信息(如密码)使用sensitive标记

### 📊 可观测性

- 统一的资源标签策略
- 完整的输出配置便于集成监控

### ✅ 代码质量

- 输入验证和约束
- 版本锁定确保环境一致性
- 规范的注释和文档

## 清理资源

```bash
# 销毁基础设施 (避免产生费用)
terraform destroy -var-file="envs/dev.tfvars"
```

## 注意事项

1. **成本控制**: 确保不使用资源时及时销毁，特别是RDS实例
2. **安全**: 生产环境请修改默认密码并使用AWS Secrets Manager
3. **备份**: 重要数据请做好备份策略
4. **监控**: 建议配置CloudWatch监控和告警

## 贡献指南

1. Fork项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 许可证

本项目仅用于学习和演示目的。

## 联系方式

如有问题或建议，请提交Issue或PR。

---

## 📚 学习资源

- [Terraform官方文档](https://www.terraform.io/docs)
- [AWS提供商文档](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform最佳实践](https://www.terraform-best-practices.com/)
