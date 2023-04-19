# 设置变量
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
BINARY_NAME=blockchain
CMD_NAME=gethost
WALLET_NAME=wallet
all: clearb clean gethost bc wa 
build: clearb clean gethost bc wa 
clean:
	$(GOCLEAN)
	cd bin && del /F $(CMD_NAME).exe && cd ..
	cd bin && del /F $(BINARY_NAME).exe && cd ..
	cd bin && del /F $(WALLET_NAME).exe && cd ..
# clearr:
# 	cls && echo -------------START RUN-------------
clearb:
	cls && echo -------------START BUILD-------------
gethost:
	cd cmd && $(GOBUILD) -o ../bin/$(CMD_NAME).exe -v && cd ..
# gethostrun:
# 	cd cmd && $(GOBUILD) -o ../bin/$(CMD_NAME).exe -v && cd ..
# 	./bin/$(CMD_NAME).exe
bc:
	cd blockchain_server && $(GOBUILD) -o ../bin/$(BINARY_NAME).exe -v && cd ..
# bcrun:
# 	cd blockchain_server && $(GOBUILD) -o ../bin/$(BINARY_NAME).exe -v && cd ..
# 	./bin/$(BINARY_NAME).exe
wa:
	cd wallet_server && $(GOBUILD) -o ../bin/$(WALLET_NAME).exe -v && cd ..
# warun:
# 	cd wallet_server && $(GOBUILD) -o ../bin/$(WALLET_NAME).exe -v && cd ..
# 	./bin/$(WALLET_NAME).exe