.PHONY: build run stop clean logs shell test help

# Variables
IMAGE_NAME := apt-cacher-ng
CONTAINER_NAME := apt-cacher-ng
PORT := 3142
VERSION := $(shell grep "ENV APT_CACHER_NG_VERSION" Dockerfile | cut -d'=' -f2)
REGISTRY := ghcr.io
REPO_NAME := user/apt-cache-docker

help: ## Show this help message
	@echo "APT Cacher NG Docker Management"
	@echo "================================"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	@echo "Building apt-cacher-ng image with version $(VERSION)..."
	docker build \
		--build-arg BUILDTIME=$$(date -u +%Y-%m-%dT%H:%M:%SZ) \
		--build-arg VERSION=$(VERSION) \
		-t $(IMAGE_NAME):latest \
		-t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):apt-cacher-ng-$(VERSION) \
		.

run: ## Run the container
	@echo "Starting apt-cacher-ng container..."
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(PORT):$(PORT) \
		-v apt-cacher-data:/var/cache/apt-cacher-ng \
		$(IMAGE_NAME):latest

compose-up: ## Start services with docker-compose
	@echo "Starting services with docker-compose..."
	docker-compose up -d

compose-down: ## Stop services with docker-compose
	@echo "Stopping services with docker-compose..."
	docker-compose down

stop: ## Stop the container
	@echo "Stopping apt-cacher-ng container..."
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

clean: ## Clean up containers and images
	@echo "Cleaning up..."
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker rmi $(IMAGE_NAME):latest 2>/dev/null || true
	docker system prune -f

logs: ## Show container logs
	docker logs -f $(CONTAINER_NAME)

shell: ## Open a shell in the running container
	docker exec -it $(CONTAINER_NAME) /bin/bash

test: ## Test the apt-cacher-ng service
	@echo "Testing apt-cacher-ng service..."
	@echo "Checking if service is running..."
	curl -f http://localhost:$(PORT)/acng-report.html || (echo "Service test failed" && exit 1)
	@echo "Service is running correctly!"

status: ## Show container status
	@echo "Container status:"
	docker ps -a --filter name=$(CONTAINER_NAME)
	@echo ""
	@echo "Image information:"
	docker images $(IMAGE_NAME)

version: ## Show version information
	@echo "APT Cacher NG Version: $(VERSION)"
	@echo "Docker Image: $(IMAGE_NAME)"
	@echo "Container: $(CONTAINER_NAME)"
	@echo "Port: $(PORT)"
	@echo "Registry: $(REGISTRY) (GitHub Container Registry only)"
	@echo "Repository: $(REPO_NAME)"

pull: ## Pull image from GHCR
	@echo "Pulling from GitHub Container Registry..."
	docker pull $(REGISTRY)/$(REPO_NAME):latest

push: ## Push image to GHCR (requires authentication)
	@echo "Pushing to GitHub Container Registry..."
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(REPO_NAME):latest
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(REPO_NAME):$(VERSION)
	docker push $(REGISTRY)/$(REPO_NAME):latest
	docker push $(REGISTRY)/$(REPO_NAME):$(VERSION)

ghcr-login: ## Login to GitHub Container Registry
	@echo "Logging in to GitHub Container Registry..."
	@echo "Please ensure GITHUB_TOKEN environment variable is set"
	@echo $$GITHUB_TOKEN | docker login ghcr.io -u $(USER) --password-stdin

setup-client: ## Configure current system to use apt-cacher-ng
	@echo "Setting up apt-cacher-ng client configuration..."
	@echo 'Acquire::HTTP::Proxy "http://localhost:$(PORT)";' | sudo tee /etc/apt/apt.conf.d/01proxy
	@echo "Client configuration completed!"

remove-client: ## Remove apt-cacher-ng client configuration
	@echo "Removing apt-cacher-ng client configuration..."
	sudo rm -f /etc/apt/apt.conf.d/01proxy
	@echo "Client configuration removed!"

dev: build run ## Build and run for development

restart: stop run ## Restart the container

rebuild: clean build run ## Clean, build and run