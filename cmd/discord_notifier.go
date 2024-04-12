package main

import (
	"bytes"
	"encoding/json"
	"log/slog"
	"net/http"
	"os"
)

type WebhookInfoEvent struct {
	WebhookUrl string      `json:"webhookUrl"`
	Data       WebhookData `json:"data"`
}

type WebhookData struct {
	Username string                   `json:"username"`
	Content  string                   `json:"content"`
	Embeds   []map[string]interface{} `json:"embeds"`
}

func ExecuteWebhook(webhookInfo WebhookInfoEvent) error {
	jsonHandler := slog.NewJSONHandler(os.Stderr, nil)
	myslog := slog.New(jsonHandler)

	// Convert data to json
	jsonData, err := json.Marshal(webhookInfo.Data)
	if err != nil {
		panic(err)
	}

	request, err := http.NewRequest("POST", webhookInfo.WebhookUrl, bytes.NewBuffer(jsonData))
	if err != nil {
		panic(err)
	}

	request.Header.Add("Content-Type", "application/json; charset=UTF-8")

	myslog.Info("Executing webhook", "contents", string(jsonData))
	client := &http.Client{}
	result, err := client.Do(request)
	if err != nil {
		panic(err)
	}

	defer result.Body.Close()

	if result.StatusCode != http.StatusOK && result.StatusCode != http.StatusNoContent {
		panic(result.Status)
	}

	return nil
}
