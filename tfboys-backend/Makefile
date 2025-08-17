.PHONY: build test clean deploy

# 构建所有服务
build:
	@echo "🔨 构建用户服务..."
	cd services/users && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags='-s -w' -o bootstrap main.go
	@echo "🔨 构建产品服务..."
	cd services/products && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags='-s -w' -o bootstrap main.go

# 运行测试
test:
	go test ./...

# 清理构建文件
clean:
	find . -name "bootstrap" -delete
	find . -name "*.zip" -delete

# 本地测试构建
build-local:
	cd services/users && go build -o bootstrap-local main.go
	cd services/products && go build -o bootstrap-local main.go
