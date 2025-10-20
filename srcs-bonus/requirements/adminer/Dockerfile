# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM		debian:bookworm-slim

# Author & Maintainer
LABEL		maintainer="aschenk"

# Install necessary packages: PHP, PHP-FPM, PHP-MySQL extension, and utilities
RUN		apt-get update && apt-get install -y --no-install-recommends \
		php-cli \
		php-fpm \
		php-mysql \
		wget \
		procps \
		&& rm -rf /var/lib/apt/lists/*

WORKDIR	/var/www/html

# Renaming to 'index.php' as php 
COPY	./tools/adminer-5.4.1-en.php index.php

EXPOSE	8080

# Start Adminer script via PHP built-in server
CMD ["php", "-S", "[::]:8080"]
