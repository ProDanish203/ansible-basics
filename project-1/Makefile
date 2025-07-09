# Makefile for Next.js Application Deployment
.PHONY: help build deploy destroy check ssh logs status clean

# Variables
APP_NAME ?= nextjs-demo
ENVIRONMENT ?= dev
TERRAFORM_DIR = ./terraform
ANSIBLE_DIR = ./ansible

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development targets
build: ## Build the Docker image
	@echo "🔨 Building Docker image..."
	docker build -t $(APP_NAME):latest .

push: ## Push Docker image to registry (configure registry first)
	@echo "📤 Pushing Docker image to registry..."
	docker tag $(APP_NAME):latest your-registry/$(APP_NAME):latest
	docker push your-registry/$(APP_NAME):latest

# Infrastructure targets
init: ## Initialize Terraform
	@echo "🚀 Initializing Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

plan: ## Plan Terraform deployment
	@echo "📋 Planning Terraform deployment..."
	cd $(TERRAFORM_DIR) && terraform plan -var="app_name=$(APP_NAME)" -var="environment=$(ENVIRONMENT)"

apply: ## Apply Terraform configuration
	@echo "🏗️  Applying Terraform configuration..."
	cd $(TERRAFORM_DIR) && terraform apply -var="app_name=$(APP_NAME)" -var="environment=$(ENVIRONMENT)"

# Deployment targets
deploy: ## Full deployment (infrastructure + application)
	@echo "🚀 Starting full deployment..."
	chmod +x deploy.sh
	./deploy.sh $(APP_NAME) $(ENVIRONMENT) deploy

ansible-only: ## Deploy only application with Ansible
	@echo "🔧 Deploying application with Ansible..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml

ansible-check: ## Run Ansible in check mode
	@echo "✅ Running Ansible check..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml --check --diff

# Management targets
ssh: ## SSH into the instance
	@INSTANCE_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_ip 2>/dev/null); \
	if [ -n "$$INSTANCE_IP" ]; then \
		echo "🔗 Connecting to $$INSTANCE_IP..."; \
		ssh -i ~/.ssh/tfkey ubuntu@$$INSTANCE_IP; \
	else \
		echo "❌ Could not get instance IP. Make sure infrastructure is deployed."; \
	fi

logs: ## Show application logs
	@INSTANCE_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_ip 2>/dev/null); \
	if [ -n "$$INSTANCE_IP" ]; then \
		echo "📋 Fetching logs from $$INSTANCE_IP..."; \
		ssh -i ~/.ssh/tfkey ubuntu@$$INSTANCE_IP "sudo docker logs $(APP_NAME)-$(ENVIRONMENT)-app -f"; \
	else \
		echo "❌ Could not get instance IP. Make sure infrastructure is deployed."; \
	fi

status: ## Check application status
	@INSTANCE_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_ip 2>/dev/null); \
	if [ -n "$$INSTANCE_IP" ]; then \
		echo "📊 Checking status on $$INSTANCE_IP..."; \
		echo "Docker containers:"; \
		ssh -i ~/.ssh/tfkey ubuntu@$$INSTANCE_IP "sudo docker ps"; \
		echo ""; \
		echo "Nginx status:"; \
		ssh -i ~/.ssh/tfkey ubuntu@$$INSTANCE_IP "sudo systemctl status nginx --no-pager"; \
		echo ""; \
		echo "Application health:"; \
		curl -s "http://$$INSTANCE_IP/health" || echo "Health check failed"; \
	else \
		echo "❌ Could not get instance IP. Make sure infrastructure is deployed."; \
	fi

# Cleanup targets
destroy: ## Destroy all infrastructure
	@echo "🗑️  Destroying infrastructure..."
	./deploy.sh $(APP_NAME) $(ENVIRONMENT) destroy

clean: ## Clean up local Docker images and containers
	@echo "🧹 Cleaning up local Docker resources..."
	docker system prune -f
	docker image prune -f

# Validation targets
check: ## Run all checks
	@echo "🔍 Running pre-deployment checks..."
	@echo "Checking Terraform..."
	cd $(TERRAFORM_DIR) && terraform validate
	@echo "Checking Ansible syntax..."
	cd $(ANSIBLE_DIR) && ansible-playbook --syntax-check playbooks/deploy.yml
	@echo "✅ All checks passed!"

# Development helpers
dev-setup: ## Set up development environment
	@echo "🛠️  Setting up development environment..."
	@if [ ! -f ~/.ssh/tfkey ]; then \
		echo "Generating SSH key pair..."; \
		ssh-keygen -t rsa -b 4096 -f ~/.ssh/tfkey -N ""; \
	fi
	@echo "Installing required tools..."
	@command -v terraform >/dev/null 2>&1 || { echo "Please install Terraform"; exit 1; }
	@command -v ansible >/dev/null 2>&1 || { echo "Please install Ansible"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "Please install Docker"; exit 1; }
	@echo "✅ Development environment ready!"

update: ## Update application (rebuild and redeploy)
	@echo "🔄 Updating application..."
	$(MAKE) build
	$(MAKE) ansible-only
