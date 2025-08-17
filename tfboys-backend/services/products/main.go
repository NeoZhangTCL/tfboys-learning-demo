package main

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"

	"tfboys-backend/shared/common"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Product 产品结构体
type Product struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Category    string  `json:"category"`
}

// 模拟产品数据
var products = []Product{
	{ID: 1, Name: "MacBook Pro", Description: "Apple laptop", Price: 2999.99, Category: "Electronics"},
	{ID: 2, Name: "iPhone 15", Description: "Apple smartphone", Price: 999.99, Category: "Electronics"},
	{ID: 3, Name: "Coffee Mug", Description: "Ceramic mug", Price: 15.99, Category: "Home"},
}

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	method, path := common.ParseMethod(event)

	fmt.Printf("Processing %s %s\n", method, path)

	// RESTful路由处理
	switch method {
	case "GET":
		return handleGetProducts(event)
	case "POST":
		return handleCreateProduct(event)
	case "PUT":
		return handleUpdateProduct(event)
	case "DELETE":
		return handleDeleteProduct(event)
	default:
		return common.ErrorResponse(405, "Method not allowed"), nil
	}
}

// GET /products 获取所有产品
// GET /products/{id} 获取单个产品
func handleGetProducts(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// 检查路径参数
	if id, exists := event.PathParameters["id"]; exists {
		// 获取单个产品
		productID, err := strconv.Atoi(id)
		if err != nil {
			return common.ErrorResponse(400, "Invalid product ID"), nil
		}

		for _, product := range products {
			if product.ID == productID {
				return common.SuccessResponse(product), nil
			}
		}
		return common.ErrorResponse(404, "Product not found"), nil
	}

	// 支持按分类筛选
	category := event.QueryStringParameters["category"]
	if category != "" {
		var filteredProducts []Product
		for _, product := range products {
			if product.Category == category {
				filteredProducts = append(filteredProducts, product)
			}
		}
		return common.SuccessResponse(map[string]interface{}{
			"products": filteredProducts,
			"total":    len(filteredProducts),
			"category": category,
		}), nil
	}

	// 获取所有产品
	return common.SuccessResponse(map[string]interface{}{
		"products": products,
		"total":    len(products),
	}), nil
}

// POST /products 创建新产品
func handleCreateProduct(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var newProduct Product
	if err := json.Unmarshal([]byte(event.Body), &newProduct); err != nil {
		return common.ErrorResponse(400, "Invalid JSON body"), nil
	}

	// 验证必填字段
	if newProduct.Name == "" || newProduct.Price <= 0 {
		return common.ErrorResponse(400, "Name and valid price are required"), nil
	}

	// 生成新ID
	newProduct.ID = len(products) + 1
	products = append(products, newProduct)

	return common.SuccessResponse(map[string]interface{}{
		"message": "Product created successfully",
		"product": newProduct,
	}), nil
}

// PUT /products/{id} 更新产品
func handleUpdateProduct(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	id, exists := event.PathParameters["id"]
	if !exists {
		return common.ErrorResponse(400, "Product ID is required"), nil
	}

	productID, err := strconv.Atoi(id)
	if err != nil {
		return common.ErrorResponse(400, "Invalid product ID"), nil
	}

	var updateData Product
	if err := json.Unmarshal([]byte(event.Body), &updateData); err != nil {
		return common.ErrorResponse(400, "Invalid JSON body"), nil
	}

	// 查找并更新产品
	for i, product := range products {
		if product.ID == productID {
			if updateData.Name != "" {
				products[i].Name = updateData.Name
			}
			if updateData.Description != "" {
				products[i].Description = updateData.Description
			}
			if updateData.Price > 0 {
				products[i].Price = updateData.Price
			}
			if updateData.Category != "" {
				products[i].Category = updateData.Category
			}
			return common.SuccessResponse(map[string]interface{}{
				"message": "Product updated successfully",
				"product": products[i],
			}), nil
		}
	}

	return common.ErrorResponse(404, "Product not found"), nil
}

// DELETE /products/{id} 删除产品
func handleDeleteProduct(event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	id, exists := event.PathParameters["id"]
	if !exists {
		return common.ErrorResponse(400, "Product ID is required"), nil
	}

	productID, err := strconv.Atoi(id)
	if err != nil {
		return common.ErrorResponse(400, "Invalid product ID"), nil
	}

	// 查找并删除产品
	for i, product := range products {
		if product.ID == productID {
			// 删除产品
			products = append(products[:i], products[i+1:]...)
			return common.SuccessResponse(map[string]interface{}{
				"message": "Product deleted successfully",
			}), nil
		}
	}

	return common.ErrorResponse(404, "Product not found"), nil
}

func main() {
	lambda.Start(handler)
}
