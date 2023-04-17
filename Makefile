# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOLINT=golangci-lint

# Output binary name
BINARY_NAME=goblockchainwoo

all: run

build:
	$(GOBUILD) -o ./bin/$(BINARY_NAME).exe -v ./...

run: 
	$(GOBUILD) -o ./bin/$(BINARY_NAME).exe -v ./...
	./bin/$(BINARY_NAME).exe

clean:
	$(GOCLEAN)
	del .\bin\$(BINARY_NAME).exe

test:
	$(GOTEST) -v ./...

test_coverage:
	$(GOTEST) -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

lint:
	$(GOLINT) run

vet:
	$(GOCMD) vet ./...
