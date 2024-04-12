.ONESHELL:

clean:
	rm bootstrap myFunction.zip

build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap -tags lambda.norpc ./cmd
	zip myFunction.zip bootstrap

deploy: clean build
	cd infra
	. ./.env
	rm -rf .terraform .terraform.lock.hcl
	terraform init -backend-config=backend.conf
	terraform plan
