# Load variables from .env
include .env
export

# Default target
.PHONY: all
all: build up

# Encode apps.json to APPS_JSON_BASE64
.PHONY: encode-apps-json
encode-apps-json:
	@if [ -f "$(APPS_JSON_PATH)" ]; then \
		echo "Encoding $(APPS_JSON_PATH) to APPS_JSON_BASE64"; \
		export APPS_JSON_BASE64=$$(cat $(APPS_JSON_PATH) | base64 -w 0); \
	else \
		echo "Error: $(APPS_JSON_PATH) not found"; \
		exit 1; \
	fi

# Build Docker image
.PHONY: build
build: encode-apps-json
	@echo "Building Docker image $(IMAGE_NAME):$(IMAGE_TAG)"
	@docker build --build-arg APPS_JSON_BASE64=$$APPS_JSON_BASE64 -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Start Docker Compose
.PHONY: up
up:
	@echo "Starting Docker Compose with image $(IMAGE_NAME):$(IMAGE_TAG)"
	@docker compose up -d

# Stop Docker Compose
.PHONY: down
down:
	@echo "Stopping Docker Compose"
	@docker compose down

# Clean up
.PHONY: clean
clean:
	@echo "Cleaning up Docker images and volumes"
	@docker compose down -v
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true