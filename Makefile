SHELL := /usr/bin/env bash

.PHONY: help init plan apply destroy start stop restart status logs install-deps prepare-host download-artifacts build-base create-sandbox validate

help:
	@printf "e2b-linux-local targets:\n"
	@printf "  make init              create /etc/e2b-linux-local.env from template\n"
	@printf "  make plan              run preflight and print deployment summary\n"
	@printf "  make apply             prepare host, install systemd units, enable and start services\n"
	@printf "  make destroy           stop and disable systemd services, keep data by default\n"
	@printf "  make start             start services\n"
	@printf "  make stop              stop services\n"
	@printf "  make restart           restart services\n"
	@printf "  make status            show service status and health\n"
	@printf "  make logs SERVICE=api  follow logs for local-infra|orchestrator|api|client-proxy\n"
	@printf "  make install-deps      install host packages\n"
	@printf "  make prepare-host      configure kernel/runtime settings\n"
	@printf "  make download-artifacts download kernels, firecrackers, busybox, envd\n"
	@printf "  make build-base        build base template once\n"
	@printf "  make create-sandbox TIMEOUT=3600 create a test sandbox\n"
	@printf "  make validate          syntax check scripts\n"

init:
	sudo ./scripts/write-env.sh
	@printf "Edit /etc/e2b-linux-local.env before running make apply.\n"

plan:
	./scripts/plan.sh

apply:
	sudo ./scripts/apply.sh

destroy:
	sudo ./scripts/destroy.sh

start:
	sudo ./scripts/e2bctl.sh start

stop:
	sudo ./scripts/e2bctl.sh stop

restart:
	sudo ./scripts/e2bctl.sh restart

status:
	./scripts/e2bctl.sh status

logs:
	./scripts/e2bctl.sh logs $(SERVICE)

install-deps:
	sudo ./scripts/install-deps.sh

prepare-host:
	sudo ./scripts/prepare-host.sh

download-artifacts:
	./scripts/download-artifacts.sh

build-base:
	./scripts/build-base-template.sh

create-sandbox:
	./scripts/create-sandbox.sh $(or $(TIMEOUT),3600)

validate:
	bash -n scripts/*.sh
