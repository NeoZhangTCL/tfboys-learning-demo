# TFBoys Backend Services

## 🏗️ 项目结构
```
tfboys-backend/
├── services/
│   ├── users/          # 用户服务
│   └── products/       # 产品服务
├── shared/
│   ├── common/         # 共享工具函数
│   └── models/         # 数据模型
├── deployments/        # 部署配置
└── tests/             # 测试代码
```

## 🚀 快速开始

### 本地开发
```bash
# 构建用户服务
cd services/users
go build -o bootstrap main.go

# 构建产品服务  
cd services/products
go build -o bootstrap main.go

# 运行测试
go test ./...
```

### 部署到AWS Lambda
```bash
# 使用优化构建 (减少50%文件大小)
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags='-s -w' -o bootstrap main.go

# 打包部署
zip lambda-deployment.zip bootstrap
```

## 📊 服务端点

### 用户服务
- `GET /users` - 获取用户列表
- `POST /users` - 创建用户
- `GET /users/{id}` - 获取指定用户
- `PUT /users/{id}` - 更新用户
- `DELETE /users/{id}` - 删除用户

### 产品服务  
- `GET /products` - 获取产品列表
- `POST /products` - 创建产品
- `GET /products/{id}` - 获取指定产品
- `PUT /products/{id}` - 更新产品
- `DELETE /products/{id}` - 删除产品
