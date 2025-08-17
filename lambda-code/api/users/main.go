package main

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"

	"serverless-api/common"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// User 用户结构体
type User struct {
	ID    int    `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

// 模拟用户数据（后面会连接真实数据库）
var users = []User{
	{ID: 1, Name: "Alice", Email: "alice@example.com"},
	{ID: 2, Name: "Bob", Email: "bob@example.com"},
	{ID: 3, Name: "Charlie", Email: "charlie@example.com"},
}

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	method, path := common.ParseMethod(event)

	fmt.Printf("Processing %s %s\n", method, path)

	// RESTful路由处理
	switch method {
	case "GET":
		return handleGetUsers(event)
	case "POST":
		return handleCreateUser(event)
	case "PUT":
		return handleUpdateUser(event)
	case "DELETE":
		return handleDeleteUser(event)
	default:
		return common.ErrorResponse(405, "Method not allowed"), nil
	}
}

// GET /users 获取所有用户
// GET /users/{id} 获取单个用户
func handleGetUsers(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// 检查路径参数
	if id, exists := event.PathParameters["id"]; exists {
		// 获取单个用户
		userID, err := strconv.Atoi(id)
		if err != nil {
			return common.ErrorResponse(400, "Invalid user ID"), nil
		}

		for _, user := range users {
			if user.ID == userID {
				return common.SuccessResponse(user), nil
			}
		}
		return common.ErrorResponse(404, "User not found"), nil
	}

	// 获取所有用户
	return common.SuccessResponse(map[string]interface{}{
		"users": users,
		"total": len(users),
	}), nil
}

// POST /users 创建新用户
func handleCreateUser(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var newUser User
	if err := json.Unmarshal([]byte(event.Body), &newUser); err != nil {
		return common.ErrorResponse(400, "Invalid JSON body"), nil
	}

	// 生成新ID
	newUser.ID = len(users) + 1
	users = append(users, newUser)

	return common.SuccessResponse(map[string]interface{}{
		"message": "User created successfully",
		"user":    newUser,
	}), nil
}

// PUT /users/{id} 更新用户
func handleUpdateUser(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	id, exists := event.PathParameters["id"]
	if !exists {
		return common.ErrorResponse(400, "User ID is required"), nil
	}

	userID, err := strconv.Atoi(id)
	if err != nil {
		return common.ErrorResponse(400, "Invalid user ID"), nil
	}

	var updateData User
	if err := json.Unmarshal([]byte(event.Body), &updateData); err != nil {
		return common.ErrorResponse(400, "Invalid JSON body"), nil
	}

	// 查找并更新用户
	for i, user := range users {
		if user.ID == userID {
			if updateData.Name != "" {
				users[i].Name = updateData.Name
			}
			if updateData.Email != "" {
				users[i].Email = updateData.Email
			}
			return common.SuccessResponse(map[string]interface{}{
				"message": "User updated successfully",
				"user":    users[i],
			}), nil
		}
	}

	return common.ErrorResponse(404, "User not found"), nil
}

// DELETE /users/{id} 删除用户
func handleDeleteUser(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	id, exists := event.PathParameters["id"]
	if !exists {
		return common.ErrorResponse(400, "User ID is required"), nil
	}

	userID, err := strconv.Atoi(id)
	if err != nil {
		return common.ErrorResponse(400, "Invalid user ID"), nil
	}

	// 查找并删除用户
	for i, user := range users {
		if user.ID == userID {
			// 删除用户
			users = append(users[:i], users[i+1:]...)
			return common.SuccessResponse(map[string]interface{}{
				"message": "User deleted successfully",
			}), nil
		}
	}

	return common.ErrorResponse(404, "User not found"), nil
}

func main() {
	lambda.Start(handler)
}
