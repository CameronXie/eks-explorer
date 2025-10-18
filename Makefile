INFRA_DIR := infrastructure
ENV_DIR := environments
ENV_INFRA_VAR_DIR := $(ENV_DIR)/$(ENV)/$(INFRA_DIR)

STACK := platform addons gitops
PROJECT := eks-explorer

# Docker Development Environment
.PHONY: up
up: create-dev-env
	@echo "Starting development environment..."
	@docker compose up --build -d

.PHONY: down
down:
	@echo "Stopping development environment..."
	@docker compose down -v

.PHONY: create-dev-env
create-dev-env:
	@if [ ! -f .env ]; then \
		echo "Creating .env from template..."; \
		cp .env.example .env; \
	else \
		echo ".env already exists"; \
	fi

# CI/CD
.PHONY: ci-%
ci-%: create-dev-env
	@docker compose run --rm dev sh -c 'make $*'

.PHONY: deploy
deploy:
	@echo "Deploying all infrastructure stacks..."
	@for s in $(STACK); do \
    	echo "Deploying stack: $$s"; \
    	$(MAKE) deploy-tf ENV=$(ENV) STACK="$$s" || { echo "Failed to deploy stack: $$s"; exit 1; }; \
    done

.PHONY: deploy-tf
deploy-tf: init-tf apply-tf

.PHONY: test
test: lint-actions lint-tf

# Terraform
.PHONY: lint-tf
lint-tf:
	@echo "Formatting and linting Terraform code..."
	@terraform -chdir=$(INFRA_DIR) fmt -recursive
	@tflint --init
	@tflint --chdir=$(INFRA_DIR) --config=$(CURDIR)/.tflint.hcl --recursive

.PHONY: init-tf
init-tf:
	@echo "Initializing $(STACK) stack for environment: $(ENV)"
	@terraform -chdir=$(INFRA_DIR)/$(STACK) init

.PHONY: plan-tf
plan-tf:
	@echo "Planning $(STACK) stack for environment: $(ENV)"
	@terraform -chdir=$(INFRA_DIR)/$(STACK) plan \
		-var-file="../../$(ENV_INFRA_VAR_DIR)/$(STACK).tfvars" \
		-var="environment=$(ENV)" \
		-var="project_name=$(PROJECT)"

.PHONY: apply-tf
apply-tf:
	@echo "Applying $(STACK) stack for environment: $(ENV)"
	@terraform -chdir=$(INFRA_DIR)/$(STACK) apply \
		-var-file="../../$(ENV_INFRA_VAR_DIR)/$(STACK).tfvars" \
		-var="environment=$(ENV)" \
		-var="project_name=$(PROJECT)" \
		-auto-approve

.PHONY: destroy-tf
destroy-tf:
	@echo "Destroying $(STACK) stack for environment: $(ENV)"
	@terraform -chdir=$(INFRA_DIR)/$(STACK) destroy \
		-var-file="../../$(ENV_INFRA_VAR_DIR)/$(STACK).tfvars" \
		-var="environment=$(ENV)" \
		-var="project_name=$(PROJECT)" \
		-auto-approve

# EKS
.PHONY: setup-kubeconfig
setup-kubeconfig:
	@echo "Configuring kubectl access to EKS cluster..."
	@CLUSTER_NAME=$$(aws ssm get-parameter \
		--name "/$(ENV)/$(PROJECT)/platform/eks/cluster-name" \
		--query "Parameter.Value" \
		--output text \
		--region $(AWS_DEFAULT_REGION) 2>/dev/null); \
	if [ -z "$$CLUSTER_NAME" ]; then \
		echo "Error: EKS cluster name not found in SSM"; \
		exit 1; \
	fi; \
	echo "Cluster name: $$CLUSTER_NAME"; \
	aws eks update-kubeconfig \
		--region $(AWS_DEFAULT_REGION) \
		--name "$$CLUSTER_NAME"

# ArgoCD
.PHONY: argocd-secret
argocd-secret:
	@echo "Retrieving ArgoCD admin password..."
	@kubectl get secret argocd-initial-admin-secret \
		-n argocd \
		--template="{{index .data.password | base64decode}}" && echo

.PHONY: argocd-login
argocd-login:
	@echo "Logging into ArgoCD..."
	@PASSWORD=$$(kubectl get secret argocd-initial-admin-secret \
		-n argocd \
		--template="{{index .data.password | base64decode}}"); \
	argocd login 0.0.0.0:8080 \
		--username admin \
		--password "$$PASSWORD" \
		--insecure

# Grafana
.PHONY: grafana-secret
grafana-secret:
	@echo "Retrieving Grafana admin password..."
	@kubectl get secret grafana \
		-n observability \
		--template="{{index .data \"admin-password\" | base64decode}}" && echo

# OpenTelemetry
.PHONY: validate-otel-config
validate-otel-config:
	@echo "Validating OpenTelemetry Collector configuration..."
	@if command -v otelcol-contrib > /dev/null 2>&1; then \
		echo "Using local otelcol-contrib binary"; \
		otelcol-contrib validate --config=apps/addons/opentelemetry-operator/config/collector-config.yaml; \
	else \
		echo "Using Docker container for validation"; \
		docker run --rm -v $(PWD)/apps/addons/opentelemetry-operator/config:/config \
			otel/opentelemetry-collector-contrib:0.95.0 \
			validate --config=/config/collector-config.yaml; \
	fi
	@echo "OpenTelemetry configuration is valid"

## Action
.PHONY: lint-actions
lint-actions:
	@actionlint
