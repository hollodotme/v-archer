.SILENT:
.PHONY: help

PROJECT = varcher
STAGE = development
DOCKER_COMPOSE_OPTIONS = -p $(PROJECT) -f docker-compose.$(STAGE).yml
DOCKER_COMPOSE_BASE_COMMAND = CURRENT_UID="$$(id -u):$$(id -g)" docker-compose $(DOCKER_COMPOSE_OPTIONS)
DOCKER_COMPOSE_EXEC_COMMAND = $(DOCKER_COMPOSE_BASE_COMMAND) exec -w /repo
DOCKER_COMPOSE_RUN_COMMAND = $(DOCKER_COMPOSE_BASE_COMMAND) run --rm -w /repo
DOCKER_COMPOSE_ISOLATED_RUN_COMMAND = $(DOCKER_COMPOSE_BASE_COMMAND) run --rm --no-deps -w /repo

CONSOLE_VERBOSITY = -v

## Build the application
build: dcup .compile dcdown
.PHONY: build

.compile:
	$(DOCKER_COMPOSE_EXEC_COMMAND) vlang v -o /repo/bin/main /repo/src/main.v
	printf "\n\e[32m✔ Build successful! Artifact exported to bin/main\e[0m\n\n"
.PHONY: compile

## Run all tests
test: dcup .runtests dcdown
.PHONY: test

.runtests:
	$(DOCKER_COMPOSE_EXEC_COMMAND) vlang v -stats test /repo
.PHONY: exectests

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

## Start docker services
dcup:
	$(DOCKER_COMPOSE_BASE_COMMAND) up -d --force-recreate
.PHONY: dcup

## Stop docker services
dcdown:
	$(DOCKER_COMPOSE_BASE_COMMAND) down --remove-orphans
.PHONY: dcdown

## Pull all containers
dcpull:
	$(DOCKER_COMPOSE_BASE_COMMAND) pull
.PHONY: dcpull

## Build all containers
dcbuild:
	docker pull mlocati/php-extension-installer
	COMPOSE_DOCKER_CLI_BUILD=1 \
	DOCKER_BUILDKIT=1 \
	$(DOCKER_COMPOSE_BASE_COMMAND) build --pull --parallel
.PHONY: dcbuild

## Show docker compose container status
dcps:
	$(DOCKER_COMPOSE_BASE_COMMAND) ps
.PHONY: dcps

## Show docker compose setup images
dcimages:
	$(DOCKER_COMPOSE_BASE_COMMAND) images
.PHONY: dcimages

## Show docker compose logs
dclogs:
	$(DOCKER_COMPOSE_BASE_COMMAND) logs -f vlang
.PHONY: dclogs

## Log into a container
dclogin:
	$(DOCKER_COMPOSE_RUN_COMMAND) vlang sh
.PHONY: dclogin
