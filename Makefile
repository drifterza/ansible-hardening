NAME = unset
REGION ?= eu-west
ENVIRONMENT ?= staging

.ONESHELL:
.SHELL := /usr/bin/bash

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

AWS_ACCESS_KEY_ID = ${TF_VAR_S3_ACCESS_KEY}
AWS_SECRET_ACCESS_KEY = ${TF_VAR_S3_SECRET_KEY}
ANSIBLE_SSH_USER = ${TF_VAR_ANSIBLE_SSH_USER}
LINODE_API_KEY = ${TF_VAR_LINODE_API_KEY}
ROOT_PASSWORD = ${TF_VAR_ROOT_PASSWORD}

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
RESET=$(shell tput sgr0)

.PHONY: apply destroy-backend destroy destroy-target plan-destroy plan plan-target prep install-roles bootstrap

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ifeq ("$(NAME)", "unset")
	@echo "ERROR: Please set solution name variable"
endif

set-env:
	@if [ -z $(NAME) ] || [ -z $(REGION) ] || [ -z $(ENVIRONMENT) ] || [ -z $(AWS_ACCESS_KEY_ID) ] || [ -z $(AWS_SECRET_ACCESS_KEY) ] || [ -z $(ANSIBLE_SSH_USER) ] || [ -z $(LINODE_API_KEY) ] || [ -z $(ROOT_PASSWORD) ]; then \
		echo "$(BOLD)$(RED)NAME or REGION or ENVIRONMENT or AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY or AWS_S3_URL or ANSIBLE_SSH_USER or LINODE_API_KEY or ROOT_PASSWORD was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`make NAME=nexus REGION=eu-west ENVIRONMENT=prod AWS_ACCESS_KEY_ID=YOURAWSKEY AWS_SECRET_ACCESS_KEY=YOURAWSSECRET ANSIBLE_SSH_USER=debian LINODE_API_KEY=SOMEGENERATEDKEY ROOT_PASSWORD=SOMEGENERATEDPASSWORD plan\`$(RESET)"; \
		exit 1; \
	 fi

prep: set-env ## Configure the tfstate backend, update any modules, and switch to the workspace
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform init \
		-force-copy \
		-lock=true \
		-upgrade \
		-verify-plugins=true \
		-backend=true \
		-backend-config="access_key=$(AWS_ACCESS_KEY_ID)" \
		-backend-config="secret_key=$(AWS_SECRET_ACCESS_KEY)" 

		@echo "$(BOLD)Switching to workspace $(NAME).$(REGION).$(ENVIRONMENT)$(RESET)"
		@cd $(ROOT_DIR)/infra-terraform && \
		terraform workspace select $(NAME).$(REGION).$(ENVIRONMENT) || terraform workspace new $(NAME).$(REGION).$(ENVIRONMENT)

plan: prep ## Show what terraform plans on doing
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="$(ROOT_DIR)/contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars"

plan-destroy: prep ## Show what terraform will destroy as a plan
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform plan \
		-input=false \
		-refresh=true \
		-destroy \
		-var-file="$(ROOT_DIR)/contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars"

apply: prep ## Create the infrastructure based off the plan
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="$(ROOT_DIR)/contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars"

auto-apply: prep ## Automatically create the infrastructure based off the plan
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		-auto-approve \
		-var-file="$(ROOT_DIR)/contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars"

destroy: prep ## Show what terraform will destroy
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="$(ROOT_DIR)/contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars"

validate: prep ## Validate Terraform syntax and formatting
	@cd $(ROOT_DIR)/infra-terraform && \
	terraform fmt \
	   -check \
	   -recursive \
		 -diff \
	   -var-file="$(ROOT_DIR)/contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars"

install-roles: ## Manually install roles
	@ansible-playbook -vv --connection=local -i 127.0.0.1, contrib/playbooks/install-roles.yml

aio: ## Manually run aio.yml, ensure roles are locally available.
	@echo "$(BOLD)Running aio.yml against host$(RESET)"
	@echo "$(BOLD)Switching to workspace $(NAME).$(REGION).$(ENVIRONMENT)$(RESET)"
	@cd $(ROOT_DIR)/infra-terraform && terraform workspace select $(NAME).$(REGION).$(ENVIRONMENT)
	@TF_STATE=infra-terraform ansible-playbook -vv -i $$(which terraform-inventory) -e "@contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(NAME)-$(ENVIRONMENT)-vars.yml" -u $(ANSIBLE_SSH_USER) contrib/playbooks/aio.yml

bootstrap: install-roles ## Bootstrap environment
	@echo "$(BOLD)Bootstrapping all nodes in inventory, use limit to reduce scope$(RESET)"
	@cd $(ROOT_DIR)/infra-terraform && terraform workspace select $(NAME).$(REGION).$(ENVIRONMENT)
	@TF_STATE=infra-terraform ansible-playbook -vv -i $$(which terraform-inventory) -e "@contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(NAME)-$(ENVIRONMENT)-vars.yml" -u $(ANSIBLE_SSH_USER) contrib/playbooks/aio.yml

ansible: ## Run generic ansible against hosts
	@echo "$(BOLD)Running $(NAME).yml against all nodes in inventory$(RESET)"
	@ansible-playbook -vv -i contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/inventory -e "@contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(NAME)-$(ENVIRONMENT)-vars.yml" -u $(ANSIBLE_SSH_USER) contrib/playbooks/$(NAME).yml

update: ## Run generic update against hosts as regular user for updates
	@echo "$(BOLD)Running $(NAME).yml against all nodes in inventory$(RESET)"
	@ansible-playbook -vv -i contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/inventory -e "@contrib/environments/$(NAME)/$(REGION)/$(ENVIRONMENT)/$(NAME)-$(ENVIRONMENT)-vars.yml" contrib/playbooks/$(NAME).yml -K
