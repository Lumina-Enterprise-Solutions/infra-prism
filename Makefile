# Makefile for Prism ERP Infrastructure - Explicit Command Version

# --- Configuration Section ---
# Define compose file paths and profiles
COMPOSE_PROD := -f docker-compose.prod.yml
COMPOSE_LOCAL := -f docker-compose.local.yml
PROFILES := --profile core --profile monitoring

# --- Default Command ---
# Running `make` without arguments will show the help message.
default: help

# --- Generic Commands (Environment Agnostic) ---
.PHONY: help ps prune

help: ## 💬 Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

ps: ## 📊 List all running docker containers on the system
	@docker ps

prune: ## 🗑️ Remove all unused containers, networks, and dangling images
	@docker system prune -f


# --- Local Environment Commands ---
.PHONY: local-up local-up-build local-down local-restart local-logs local-clean local-migrate-up local-migrate-down

local-up: ## 🚀 [LOCAL] Start all local services
	@echo "Starting up local services..."
	docker compose $(COMPOSE_LOCAL) $(PROFILES) up -d --remove-orphans

local-up-build: ## 🚀 [LOCAL] Start all local services
	@echo "Starting up local services..."
	docker compose $(COMPOSE_LOCAL) $(PROFILES) up -d --build --remove-orphans

local-down: ## ⏹️ [LOCAL] Stop and remove local services
	@echo "Stopping local services..."
	docker-compose $(COMPOSE_LOCAL) $(PROFILES) down

local-restart: ## 🔄 [LOCAL] Restart all local services
	$(MAKE) local-down
	$(MAKE) local-up

local-logs: ## 📜 [LOCAL] View logs. Usage: make local-logs s=<service>
ifdef s
	@echo "Showing logs for local service [$(s)]..."
	@docker compose $(COMPOSE_LOCAL) logs -f $(s)
else
	@echo "Showing logs for all local services..."
	@docker compose $(COMPOSE_LOCAL) $(PROFILES) logs -f
endif

local-clean: ## 🧹 [LOCAL] Stop services and REMOVE ALL DATA VOLUMES. USE WITH CAUTION!
	@read -p "🚨 This will delete all LOCAL data (Postgres, Redis, etc). Are you sure? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "Cleaning up local environment..."; \
		docker compose $(COMPOSE_LOCAL) $(PROFILES) down -v; \
	else \
		echo "Cleanup cancelled."; \
	fi

local-migrate-up: ## ⬆️  [LOCAL] Apply all database migrations
	@echo "Running database migrations up on local DB..."
	docker compose $(COMPOSE_LOCAL) run --rm migrate up

local-migrate-down: ## ⬇️  [LOCAL] Revert all database migrations
	@echo "Reverting all database migrations on local DB..."
	docker compose $(COMPOSE_LOCAL) run --rm migrate down


# --- Production Environment Commands ---
.PHONY: prod-up prod-down prod-restart prod-logs prod-clean prod-migrate-up prod-migrate-down

prod-up: ## 🚀 [PROD] Start all production services
	@echo "Starting up production services..."
	docker compose $(COMPOSE_PROD) $(PROFILES) up -d --remove-orphans

prod-down: ## ⏹️ [PROD] Stop and remove production services
	@echo "Stopping production services..."
	docker compose $(COMPOSE_PROD) $(PROFILES) down

prod-restart: ## 🔄 [PROD] Restart all production services
	$(MAKE) prod-down
	$(MAKE) prod-up

prod-logs: ## 📜 [PROD] View logs. Usage: make prod-logs s=<service>
ifdef s
	@echo "Showing logs for production service [$(s)]..."
	@docker compose $(COMPOSE_PROD) logs -f $(s)
else
	@echo "Showing logs for all production services..."
	@docker compose $(COMPOSE_PROD) $(PROFILES) logs -f
endif

prod-clean: ## 🧹 [PROD] Stop services and REMOVE ALL DATA VOLUMES. USE WITH CAUTION!
	@read -p "🚨 This will delete all PRODUCTION data (Postgres, Redis, etc). Are you sure? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "Cleaning up production environment..."; \
		docker compose $(COMPOSE_PROD) $(PROFILES) down -v; \
	else \
		echo "Cleanup cancelled."; \
	fi

prod-migrate-up: ## ⬆️  [PROD] Apply all database migrations
	@echo "Running database migrations up on production DB..."
	docker compose $(COMPOSE_PROD) run --rm migrate up

prod-migrate-down: ## ⬇️  [PROD] Revert all database migrations
	@echo "Reverting all database migrations on production DB..."
	docker compose $(COMPOSE_PROD) run --rm migrate down


.PHONY: e2e-test

e2e-test: ## 🔬 [PROD] Run end-to-end tests using Newman against a running production stack
	@echo "Starting E2E test run..."
	@echo "-> Ensuring production stack is up..."
	@$(MAKE) prod-up
	@echo "-> Waiting for services to be healthy (giving 30 seconds)..."
	@sleep 30
	@echo "-> Running Newman Postman collection..."
	@docker run --rm -v $(CURDIR)/postman:/etc/postman -t --network=host postman/newman:latest run "Prism Enterprise Services.postman_collection.json" --env-var "base_url=http://localhost:8000" --reporters cli,junit --reporter-junit-export /etc/postman/e2e-report.xml
	@echo "✅ E2E test run finished. Report available at postman/e2e-report.xml"
