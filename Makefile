GOHOSTOS:=$(shell go env GOHOSTOS)
GOPATH:=$(shell go env GOPATH)
VERSION:=$(shell git describe --tags --always)
NAME:=$(shell basename `pwd` )





ifeq ($(GOHOSTOS), windows)
	#the `find.exe` is different from `find` in bash/shell.
	#to see https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/find.
	#changed to use git-bash.exe to run find cli or other cli friendly, caused of every developer has a Git.
	Git_Bash= $(subst cmd\,bin\bash.exe,$(dir $(shell where git)))
	INTERNAL_PROTO_FILES=$(shell $(Git_Bash) -c "find internal -name *.proto")
	API_PROTO_FILES=$(shell $(Git_Bash) -c "find api -name *.proto")
else
	INTERNAL_PROTO_FILES=$(shell find internal -name *.proto)
	API_PROTO_FILES=$(shell find api -name *.proto)
endif

.PHONY: init
# init env
init:
	GOPROXY=https://goproxy.cn/,direct go install github.com/zeromicro/go-zero/tools/goctl@latest


.PHONY: add.api
# init env
add.api:
	cd restful && goctl api new $(NAME)



.PHONY: start
# starte
start:
	cd "restful/$(NAME)" && \
    go mod tidy && \
	CGO_ENABLED=0 GOOS=darwin  GOARCH=arm64 go install   -ldflags="-s -w"  -ldflags "-X main.Version=$(VERSION)"  -ldflags "-X main.Name=$$NAME"  $(NAME).go && \
	mkdir -p "$(GOPATH)/restful/$(NAME)/etc/" && \
	cp -rf  "etc/$(NAME)-api.yaml" "$(NAME)-api.yaml" && \
	"$(GOPATH)/bin/$(NAME)" -f "$(NAME)-api.yaml"




.PHONY: all
# generate all
all:


# show help
help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, sdfsdfsdfdsfsdfsfRSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
