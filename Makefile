NAME :=				Inception

DOCKER_COMP_F :=	srcs/docker-compose.yml

RESET =				\033[0m
BOLD =				\033[1m
GREEN =				\033[32m
YELLOW =			\033[33m
RED :=				\033[91m


###########
## RULES ##
###########

all:
	@echo "$(BOLD)$(GREEN)🐳 Building images and starting services in detached mode...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) up --build -d
	@echo "$(BOLD)$(GREEN)\n✅ Project $(YELLOW)$(NAME)$(GREEN) is now running in the background.$(RESET)"
	@echo "$(YELLOW)\nUsage: XXXX$(RESET)"

# Stops containers and networks. Named volumes (data) and images are kept.
# Purely a runtime cleanup.
clean:
	@echo "$(BOLD)$(RED)🐳 Stopping services and removing containers and networks...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) down
	@echo "$(BOLD)$(RED)\n🗑️  All Docker containers and networks have been removed.$(RESET)"

# Stops everything and removes containers, networks, images, and volumes.
# This performs the complete environment reset.
fclean:
	@echo "$(BOLD)$(RED)💥 FULL CLEANUP: Removing containers, networks, images, and volumes...$(RESET)"
	@docker compose -f $(DOCKER_COMP_F) down --rmi all --volumes
	@echo "$(BOLD)$(RED)\n🗑️  All Docker containers, networks, images, and volumes have been removed.$(RESET)"

re:	fclean all

.PHONY: all clean fclean re
