clean:
	rm bootstrap myFunction.zip

build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap -tags lambda.norpc ./cmd
	zip myFunction.zip bootstrap
