# Load variables from .env
include .env
export

# Default target
.PHONY: all
all: check-env build up

# Check .env for trailing spaces
.PHONY: check-env
check-env:
	@echo "Checking .env for trailing spaces"
	@if grep -E '[[:space:]]$$' .env; then \
		echo "Error: Trailing spaces found in .env"; \
		exit 1; \
	else \
		echo ".env is clean"; \
	fi

# Encode apps.json to APPS_JSON_BASE64
.PHONY: encode-apps-json
encode-apps-json:
	@if [ -f "$(APPS_JSON_PATH)" ]; then \
		echo "Encoding $(APPS_JSON_PATH) to APPS_JSON_BASE64"; \
		base64 -w 0 $(APPS_JSON_PATH) > .apps_json_base64; \
		echo "APPS_JSON_BASE64 file created"; \
	else \
		echo "Error: $(APPS_JSON_PATH) not found"; \
		exit 1; \
	fi

# Build Docker image
.PHONY: build
build: encode-apps-json
	@echo "Building Docker image $(IMAGE_NAME):$(IMAGE_TAG) with no cache"
	@docker build --no-cache --build-arg APPS_JSON_BASE64="$$(cat .apps_json_base64)" -t $(IMAGE_NAME):$(IMAGE_TAG) .

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
	@rm -f .apps_json_base64