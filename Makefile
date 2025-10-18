NAME :=				Inception

DOCKER_COMP_F :=	srcs/docker-compose.yml

RESET =				\033[0m
BOLD =				\033[1m
GREEN =				\033[32m
YELLOW =			\033[33m
RED :=				\033[91m

# Load environment variables from .env file
ENV_FILE :=			srcs/.env

# If env file exists, include (into Makefile) and export (into shell) variables
ifneq ($(wildcard $(ENV_FILE)),)
	include $(ENV_FILE)
	export $(shell sed 's/=.*//' $(ENV_FILE) | xargs)
endif

###########
## RULES ##
###########

all: build up

build:
	@echo "$(BOLD)$(GREEN)📁 Creating host directories for volumes...$(RESET)"
	sudo mkdir -p $(VOLUME_PATH)db_data
	sudo mkdir -p $(VOLUME_PATH)wp_data
	@echo "$(BOLD)$(GREEN)🐳 Building Docker images...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) build

up:
	@echo "$(BOLD)$(GREEN)🐳 Starting services in detached mode...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) up -d
	@echo "$(BOLD)$(GREEN)\n✅ Project $(YELLOW)$(NAME)$(GREEN) is now running in the background.$(RESET)"
	@echo "$(YELLOW)\nUsage: Access the website here: $(BOLD)https://$(DOMAIN_NAME)$(RESET)"

clean:
	@echo "$(BOLD)$(RED)🐳 Stopping services and removing containers and networks...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) down
	@echo "$(BOLD)$(RED)\n🗑️  All Docker containers and networks have been removed.$(RESET)"

# Stops everything and removes containers, networks, images, and volumes.
# This performs the complete environment reset.
## 1. Take down the entire project stack (containers, networks, images, volumes)
## 2. Prune any remaining ressources (dangling images, build cache)
## 3. Make sure that all volumes are REALLY removed
fclean:
	@echo "$(BOLD)$(RED)💥 FULL CLEANUP: Removing containers, networks, images, and volumes...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) down --rmi all --volumes
	@docker system prune -af --volumes
	@docker volume ls -q | xargs -r docker volume rm
	@sudo rm -rf $(VOLUME_PATH)
	@echo "$(BOLD)$(RED)\n🗑️  All Docker containers, networks, images, and volumes have been removed.$(RESET)"

pause:
	@echo "$(BOLD)$(YELLOW)Pause all running containers... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) pause

unpause:
	@echo "$(BOLD)$(YELLOW)Unpause all running containers... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) unpause

stop:
	@echo "$(BOLD)$(RED)Stopping all services... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) stop

start:
	@echo "$(BOLD)$(GREEN)Starting all services... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) start

status:
	@echo "$(BOLD)$(YELLOW)Current status of all services: $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) ps

re: fclean all

.PHONY: all build up clean fclean pause unpause stop start re status
