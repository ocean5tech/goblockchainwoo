# 定义Go编译器和参数
GO=go
GOFLAGS=-v

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOLINT=golangci-lint


# 定义项目名称和目录
PROJECTS=BLOCK WALLET 
BLOCK_DIR=./block
WALLET_DIR=./wallet

# Output binary name
BINARY_NAME_BLOCK=block
BINARY_NAME_WALLET=wallet




# 定义编译目标
all: BLOCK WALLET

BLOCK:
	go build -o ./bin/blockchain.exe ./block/blockchain.go

WALLET:
	go build -o ./bin/wallet.exe ./wallet/wallet.go

runb:
	./bin/blockchain.exe
runw:
	./bin/wallet.exe
# build:
# 	$(GOBUILD) -o ./bin/$(BINARY_NAME).exe -v ./...

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
