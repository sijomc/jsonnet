DIR_NAME := $(shell basename `pwd`)
CONFIG := config.jsonnet
DOCKER_COMPOSE_ENV := .env
DOCKER_NETWORK_DEFAULT := appliance
PRE_BUILD := $(shell jsonnet --ext-str containerName=$(DIR_NAME) --ext-str networkName=$(DOCKER_NETWORK_DEFAULT) -o $(DOCKER_COMPOSE_ENV) -S $(CONFIG))