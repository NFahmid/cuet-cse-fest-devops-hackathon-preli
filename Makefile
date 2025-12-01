.PHONY: help dev-up dev-down dev-build dev-logs dev-restart dev-ps dev-shell backend-shell gateway-shell mongo-shell prod-up prod-down prod-build prod-logs prod-restart backend-build backend-install backend-type-check backend-dev db-reset db-backup clean clean-all clean-volumes status health help

DEV_COMPOSE := docker compose -f docker/compose.development.yaml
PROD_COMPOSE := docker compose -f docker/compose.production.yaml

# ============================================================================
# Development Targets
# ============================================================================

dev-up:
	@echo "Starting development environment..."
	$(DEV_COMPOSE) up -d

dev-down:
	@echo "Stopping development environment..."
	$(DEV_COMPOSE) down

dev-build:
	@echo "Building development containers..."
	$(DEV_COMPOSE) build

dev-restart:
	@echo "Restarting development services..."
	$(DEV_COMPOSE) restart

dev-logs:
	@echo "Tailing development logs (Ctrl+C to exit)..."
	$(DEV_COMPOSE) logs -f

dev-ps:
	@echo "Development containers:"
	$(DEV_COMPOSE) ps

dev-shell:
	@echo "Opening shell in backend container..."
	$(DEV_COMPOSE) exec backend sh

# ============================================================================
# Production Targets
# ============================================================================

prod-up:
	@echo "Starting production environment..."
	$(PROD_COMPOSE) up -d

prod-down:
	@echo "Stopping production environment..."
	$(PROD_COMPOSE) down

prod-build:
	@echo "Building production containers..."
	$(PROD_COMPOSE) build

prod-logs:
	@echo "Tailing production logs (Ctrl+C to exit)..."
	$(PROD_COMPOSE) logs -f

prod-restart:
	@echo "Restarting production services..."
	$(PROD_COMPOSE) restart

# ============================================================================
# Container Shells
# ============================================================================

backend-shell:
	$(DEV_COMPOSE) exec backend sh

gateway-shell:
	$(DEV_COMPOSE) exec gateway sh

mongo-shell:
	$(DEV_COMPOSE) exec mongo mongosh -u devuser -p devpass --authenticationDatabase admin

# ============================================================================
# Backend (Local, non-Docker)
# ============================================================================

backend-install:
	cd backend && npm install

backend-build:
	cd backend && npm run build

backend-type-check:
	cd backend && npm run type-check

backend-dev:
	cd backend && npm run dev

# ============================================================================
# Database
# ============================================================================

db-reset:
	@echo "WARNING: Resetting MongoDB database..."
	@echo "Type 'yes' to confirm: " && read -r CONFIRM && \
	if [ "$$CONFIRM" = "yes" ]; then \
	  $(DEV_COMPOSE) exec mongo mongosh -u devuser -p devpass --authenticationDatabase admin --eval "db.dropDatabase()"; \
	  echo "Database reset complete."; \
	else \
	  echo "Cancelled."; \
	fi

db-backup:
	@echo "Backing up MongoDB..."
	@mkdir -p ./backups
	$(DEV_COMPOSE) exec mongo mongodump --uri="mongodb://devuser:devpass@mongo:27017" --out=/data/backup
	@echo "Backup complete"

# ============================================================================
# Cleanup
# ============================================================================

clean:
	@echo "Removing development and production containers and networks..."
	$(DEV_COMPOSE) down 2>/dev/null || true
	$(PROD_COMPOSE) down 2>/dev/null || true

clean-all: clean
	@echo "Removing all volumes and images..."
	docker volume rm mongo_data 2>/dev/null || true
	docker volume rm mongo_data_prod 2>/dev/null || true
	docker rmi ecommerce-backend:latest 2>/dev/null || true
	docker rmi ecommerce-gateway:latest 2>/dev/null || true

clean-volumes:
	@echo "Removing all named volumes..."
	docker volume rm mongo_data 2>/dev/null || true
	docker volume rm mongo_data_prod 2>/dev/null || true

# ============================================================================
# Utilities
# ============================================================================

status: dev-ps

health:
	@echo "Checking service health..."
	@echo "Gateway health:"
	@curl -s http://localhost:5921/health || echo "Gateway unavailable"
	@echo ""
	@echo "Backend health:"
	@curl -s http://localhost:5921/api/health || echo "Backend unavailable"

# ============================================================================
# Help
# ============================================================================

help:
	@echo "E-Commerce DevOps Hackathon - Makefile"
	@echo ""
	@echo "Development:"
	@echo "  make dev-up         Start development environment"
	@echo "  make dev-down       Stop development environment"
	@echo "  make dev-build      Build development containers"
	@echo "  make dev-restart    Restart development services"
	@echo "  make dev-logs       View development logs"
	@echo "  make dev-ps         Show running development containers"
	@echo ""
	@echo "Production:"
	@echo "  make prod-up        Start production environment"
	@echo "  make prod-down      Stop production environment"
	@echo "  make prod-build     Build production containers"
	@echo "  make prod-logs      View production logs"
	@echo ""
	@echo "Container Shells:"
	@echo "  make dev-shell      Open shell in backend container"
	@echo "  make backend-shell  Open shell in backend container"
	@echo "  make gateway-shell  Open shell in gateway container"
	@echo "  make mongo-shell    Open MongoDB shell"
	@echo ""
	@echo "Backend (Local):"
	@echo "  make backend-install    Install backend dependencies"
	@echo "  make backend-build      Build backend TypeScript"
	@echo "  make backend-type-check Type check backend code"
	@echo "  make backend-dev        Run backend in dev mode locally"
	@echo ""
	@echo "Database:"
	@echo "  make db-reset     Reset MongoDB (WARNING: destructive)"
	@echo "  make db-backup    Backup MongoDB database"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean        Remove containers/networks"
	@echo "  make clean-all    Remove containers, volumes, and images"
	@echo "  make clean-volumes Remove named volumes only"
	@echo ""
	@echo "Utilities:"
	@echo "  make status       Show running containers"
	@echo "  make health       Check service health endpoints"
	@echo "  make help         Display this help message"

