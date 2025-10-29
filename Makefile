# =============================================================================
# Makefile para Sistema Solis PDV
# =============================================================================
# Uso no Windows PowerShell: Instale make via chocolatey ou use os comandos docker-compose diretamente

.PHONY: help build up down restart logs clean dev

# Cores para output
BLUE=\033[0;34m
GREEN=\033[0;32m
NC=\033[0m # No Color

help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)Sistema Solis PDV - Comandos Disponíveis$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

build: ## Build de todos os containers
	docker-compose build

up: ## Inicia todos os serviços
	docker-compose up -d
	@echo "$(GREEN)✓ Serviços iniciados!$(NC)"
	@echo "App Admin: http://localhost:8081"
	@echo "App PWA: http://localhost:8080"
	@echo "API: http://localhost:3000"

down: ## Para todos os serviços
	docker-compose down
	@echo "$(GREEN)✓ Serviços parados$(NC)"

restart: down up ## Reinicia todos os serviços

logs: ## Mostra logs de todos os serviços
	docker-compose logs -f

logs-api: ## Mostra logs da API
	docker-compose logs -f solis-api

logs-agente: ## Mostra logs do Agente PDV
	docker-compose logs -f agente-pdv

logs-db: ## Mostra logs do banco de dados
	docker-compose logs -f postgres

ps: ## Lista status dos containers
	docker-compose ps

dev: ## Inicia em modo desenvolvimento
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

dev-build: ## Build e inicia em modo desenvolvimento
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build

clean: ## Remove containers, volumes e imagens
	docker-compose down -v --rmi all
	@echo "$(GREEN)✓ Limpeza completa realizada$(NC)"

db-backup: ## Cria backup do banco de dados
	docker-compose exec postgres pg_dump -U solis_user solis_pdv > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Backup criado$(NC)"

db-restore: ## Restaura backup do banco (use BACKUP_FILE=arquivo.sql)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Uso: make db-restore BACKUP_FILE=backup.sql"; \
	else \
		docker-compose exec -T postgres psql -U solis_user solis_pdv < $(BACKUP_FILE); \
		echo "$(GREEN)✓ Backup restaurado$(NC)"; \
	fi

shell-api: ## Acessa shell da API
	docker-compose exec solis-api sh

shell-agente: ## Acessa shell do Agente PDV
	docker-compose exec agente-pdv sh

shell-db: ## Acessa shell do banco de dados
	docker-compose exec postgres psql -U solis_user -d solis_pdv

test: ## Executa testes
	docker-compose exec solis-api npm test

install: build up ## Primeira instalação (build + up)
	@echo "$(GREEN)✓ Sistema instalado com sucesso!$(NC)"
	@echo ""
	@echo "Acesse:"
	@echo "  Admin: http://localhost:8081"
	@echo "  PWA: http://localhost:8080"
	@echo ""
	@echo "Credenciais padrão:"
	@echo "  Email: admin@solis.com"
	@echo "  Senha: admin123"
