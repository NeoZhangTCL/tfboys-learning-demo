package common

import (
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
)

// APIResponse 标准API响应结构
type APIResponse struct {
	StatusCode int               `json:"statusCode"`
	Body       string            `json:"body"`
	Headers    map[string]string `json:"headers"`
}

// SuccessResponse 创建成功响应
func SuccessResponse(data interface{}) events.APIGatewayProxyResponse {
	body, _ := json.Marshal(map[string]interface{}{
		"success": true,
		"data":    data,
	})

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(body),
		Headers: map[string]string{
			"Content-Type":                "application/json",
			"Access-Control-Allow-Origin": "*",
		},
	}
}

// ErrorResponse 创建错误响应
func ErrorResponse(statusCode int, message string) events.APIGatewayProxyResponse {
	body, _ := json.Marshal(map[string]interface{}{
		"success": false,
		"error":   message,
	})

	return events.APIGatewayProxyResponse{
		StatusCode: statusCode,
		Body:       string(body),
		Headers: map[string]string{
			"Content-Type":                "application/json",
			"Access-Control-Allow-Origin": "*",
		},
	}
}

// ParseMethod 解析HTTP方法和路径
func ParseMethod(event events.APIGatewayProxyRequest) (string, string) {
	return event.HTTPMethod, event.Path
}
