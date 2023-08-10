.SILENT:
.PHONY: help

PROJECT = 'v-archer'
V_PATH = ''
V_COMMAND = $(V_PATH)v
BUILD_TARGET = ./bin/v-archer

## Build the application
build:
	mkdir -p ./bin
	$(V_COMMAND) install
	$(V_COMMAND) -o $(BUILD_TARGET) ./src/main.v
	printf "\n\e[32m✔ Build successful! Artifact exported to $(BUILD_TARGET)\e[0m\n\n"
.PHONY: build

## Verify code is formatted
verifyfmt:
	$(V_COMMAND) fmt -diff .
	$(V_COMMAND) fmt -verify .
.PHONY: verifyfmt

## Run all tests
test: verifyfmt
	$(V_COMMAND) -stats test ./src
.PHONY: test

## Update v and dependencies
update:
	$(V_COMMAND) up
	$(V_COMMAND) update
.PHONY: update

## This help screen
help:
	printf "Available commands\n\n"
	awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "\033[33m%-40s\033[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
.PHONY: help
