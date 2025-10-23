NAME :=				inception

DOCKER_COMP_F :=	srcs/docker-compose.yml
DOCKER_BONUS_F :=	srcs-bonus/docker-compose.yml

RESET =				\033[0m
BOLD =				\033[1m
GREEN =				\033[32m
YELLOW =			\033[33m
RED :=				\033[91m

# Load environment variables from .env file
ENV_FILE :=			srcs-bonus/.env

# If env file exists, include (into Makefile) and export (into shell) variables
ifneq ($(wildcard $(ENV_FILE)),)
	include $(ENV_FILE)
	export $(shell sed 's/=.*//' $(ENV_FILE) | xargs)
endif

## CHECK IF SECRETS ARE AVAILABLE ##

SECRET_DB_ROOT_PASS_MAKE   := secrets/db_root_password.txt
SECRET_DB_USER_PASS_MAKE   := secrets/db_user_password.txt
SECRET_WP_ADMIN_PASS_MAKE  := secrets/wp_admin_password.txt
SECRET_WP_USER_PASS_MAKE   := secrets/wp_user_password.txt
SECRET_SSL_PUB_KEY_MAKE    := secrets/inception.crt
SECRET_SSL_PRIV_KEY_MAKE   := secrets/inception.key
SECRET_FTP_USER_PASS_MAKE  := secrets/ftp_user_password.txt

SECRET_FILES :=				$(SECRET_DB_ROOT_PASS_MAKE) \
							$(SECRET_DB_USER_PASS_MAKE) \
							$(SECRET_WP_ADMIN_PASS_MAKE) \
							$(SECRET_WP_USER_PASS_MAKE) \
							$(SECRET_SSL_PUB_KEY_MAKE) \
							$(SECRET_SSL_PRIV_KEY_MAKE)

# CHECK_SECRETS contains a list of all files that DO NOT exist.
CHECK_SECRETS :=			$(strip $(foreach file,$(SECRET_FILES),\
								$(if $(wildcard $(file)),,\
									$(file))) )

########### 
## RULES ##
###########

all: build up

build:
	@echo "$(BOLD)$(GREEN)🤫 Checking required secret file...$(RESET)"
	@if [ -n "$(CHECK_SECRETS)" ]; then \
		echo "$(RED)$(BOLD)ERROR: Missing secret file(s)!$(RESET)" >&2; \
		echo "Please create the following file(s) relative to the Makefile:" >&2; \
		echo "$(YELLOW)$(CHECK_SECRETS)$(RESET)" >&2; \
		exit 1; \
	fi

	@echo "$(BOLD)$(GREEN)📁 Creating host directories for volumes...$(RESET)"
	sudo mkdir -p $(VOLUME_PATH)db_data
	sudo mkdir -p $(VOLUME_PATH)wp_data
	@echo "$(BOLD)$(GREEN)🐳 Building Docker images...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) build

up:
	@echo "$(BOLD)$(GREEN)🐳 Starting services in detached mode...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -p $(NAME) up -d
	@echo "$(BOLD)$(GREEN)\n✅ Project $(YELLOW)$(NAME)$(GREEN) is now running in the background.$(RESET)"
	@echo "$(YELLOW)\nUsage: Access the website here: $(BOLD)https://$(DOMAIN_NAME)$(RESET)"

bonus: build_bonus up_bonus

build_bonus:
	@echo "$(BOLD)$(GREEN)🤫 Checking required secret file...$(RESET)"
	@if [ -n "$(CHECK_SECRETS)" ]; then \
		echo "$(RED)$(BOLD)ERROR: Missing secret file(s)!$(RESET)" >&2; \
		echo "Please create the following file(s) relative to the Makefile:" >&2; \
		echo "$(YELLOW)$(CHECK_SECRETS)$(RESET)" >&2; \
		exit 1; \
	fi

	@if [ ! -f "$(SECRET_FTP_USER_PASS_MAKE)" ]; then \
		echo "$(RED)$(BOLD)ERROR: Missing secret file(s)!$(RESET)" >&2; \
		echo "Please create the following file(s) relative to the Makefile:" >&2; \
		echo "$(YELLOW)$(SECRET_FTP_USER_PASS_MAKE)$(RESET)" >&2; \
		exit 1; \
	fi
	
	@echo "$(BOLD)$(GREEN)📁 Creating host directories for bonus volumes...$(RESET)"
	sudo mkdir -p $(VOLUME_PATH)db_data
	sudo mkdir -p $(VOLUME_PATH)wp_data
	@echo "$(BOLD)$(GREEN)🐳 Building Docker images from bonus stack...$(RESET)"
	@docker compose -f $(DOCKER_BONUS_F) build

up_bonus:
	@echo "$(BOLD)$(GREEN)🐳 Starting bonus services in detached mode...$(RESET)"
	@docker compose -f $(DOCKER_BONUS_F) -p $(NAME) up -d
	@echo "$(BOLD)$(GREEN)\n✅ Project $(YELLOW)$(NAME)$(GREEN) (Bonus) is now running in the background.$(RESET)"
	@echo "$(YELLOW)\nUsage: Access the website here: $(BOLD)https://$(DOMAIN_NAME)$(RESET)\n"
	@echo "Bonus: Access $(YELLOW)static site$(RESET) here: $(BOLD)https://$(DOMAIN_NAME)/$(STATIC_SITE)$(RESET)"
	@echo "Bonus: Access $(YELLOW)Redis Explorer$(RESET) here: $(BOLD)https://$(DOMAIN_NAME)/redis-explorer$(RESET)"
	@echo "Bonus: Access $(YELLOW)Adminer$(RESET) here: $(BOLD)localhost:8080$(RESET)"
	@echo "Bonus: Access $(YELLOW)FTP$(RESET) with: $(BOLD)localhost:21$(RESET) (use clients like FileZilla)"

clean:
	@echo "$(BOLD)$(RED)🐳 Stopping services and removing containers and networks...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) -p $(NAME) down
	@echo "$(BOLD)$(RED)🗑️  All Docker containers and networks have been removed.$(RESET)"

# Stops everything and removes containers, networks, images, and volumes.
# This performs the complete environment reset.
## 1. Take down the entire project stack (containers, networks, images, volumes)
## 2. Prune any remaining ressources (dangling images, build cache)
## 3. Make sure that all volumes are REALLY removed
fclean: clean
	@echo "$(BOLD)$(RED)💥 FULL CLEANUP: Removing images and volumes...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) -p $(NAME) down --rmi all --volumes
	@docker system prune -af --volumes
	@sudo rm -rf $(VOLUME_PATH)
	@echo "$(BOLD)$(RED)🗑️  All Docker ressources have been removed.$(RESET)"

pause:
	@echo "$(BOLD)$(YELLOW)Pause all running containers... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) pause

unpause:
	@echo "$(BOLD)$(YELLOW)Unpause all running containers... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) unpause

stop:
	@echo "$(BOLD)$(RED)Stopping all services... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) -p $(NAME) stop

start:
	@echo "$(BOLD)$(GREEN)Starting all services... $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) -p $(NAME) start

status:
	@echo "$(BOLD)$(YELLOW)Current status of all services: $(RESET)"
	@docker compose -f $(DOCKER_COMP_F) -f $(DOCKER_BONUS_F) -p $(NAME) ps

re: fclean all

re_bonus: fclean bonus

.PHONY: all build build_bonus up up_bonus clean fclean pause unpause stop start re re_bonus status
