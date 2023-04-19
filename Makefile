# 设置变量
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
BINARY_NAME=goblockchainwoo
all: clear clean build run
clear:
    cls && echo -------------Start Making-------------
build:
    $(GOBUILD) -o $(BINARY_NAME).exe -v
clean:
    $(GOCLEAN)
    del /F $(BINARY_NAME).exe
run:
    $(BINARY_NAME).exe