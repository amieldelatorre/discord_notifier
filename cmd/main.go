package main

import (
	"context"

	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(LambdaHandler)
}

func LambdaHandler(ctx context.Context, event *WebhookInfoEvent) error {
	ExecuteWebhook(*event)
	return nil

}
