default: configure

## Show the $(DOCKER_COMPOSE_ENV) file that was created by $(CONFIG)
configure:
	echo "Using Docker Compose $(DOCKER_COMPOSE_ENV) file generated from $(CONFIG)"
	cat $(DOCKER_COMPOSE_ENV)
ifdef POST_SETUP_SCRIPT
	echo "POST_SETUP_SCRIPT=$(POST_SETUP_SCRIPT)"
endif

## If the container is running, inspect its settings
inspect: configure
	docker ps -a | grep $(CONTAINER_NAME)
	docker volume inspect $(VOLUME_NAME)
	docker port $(CONTAINER_NAME)

## If the container is running, show its logs
logs: configure
	docker logs $(CONTAINER_NAME)

## Start the container and all dependencies
start: configure
	docker volume create $(VOLUME_NAME)
	docker volume inspect $(VOLUME_NAME) --format "Volume $(VOLUME_NAME) mountpoint: {{json .Mountpoint }}"
	docker-compose up -d --force-recreate
ifdef POST_SETUP_SCRIPT
	if [[ -x "$(POST_SETUP_SCRIPT)" ]]; then
		$(POST_SETUP_SCRIPT)
	fi
endif

## Stop the container but retain external volumes and networks.
stop: configure
	echo "Stopping $(CONTAINER_NAME)"
	docker-compose down

## DANGEROUS: Stop the container and REMOVE all dependencies.
clean: stop configure
	echo "Removing volume $(VOLUME_NAME)"
	docker volume rm $(VOLUME_NAME)
	rm -f $(DOCKER_COMPOSE_ENV)

TARGET_MAX_CHAR_NUM=10
## All targets should have a ## Help text above the target and they'll be automatically collected
## Show help, using auto generator from https://gist.github.com/prwhite/8168133
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
