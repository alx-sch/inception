# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM	debian:bookworm-slim

# Author & Maintainer
LABEL	maintainer="aschenk"

# Install necessary packages: PHP, PHP-FPM, PHP-MySQL extension, and utilities
# - php-cli: Runs PHP scripts from the command line.
# - php-mysql: The extension that allows PHP to communicate with MariaDB.
# - wget: A utility for downloading files from the internet.
# - ca-certificates: Allows HTTPS downloads.
RUN		apt-get update && apt-get install -y --no-install-recommends \
		php-cli \
		php-mysql \
		wget \
		ca-certificates \
		&& rm -rf /var/lib/apt/lists/*

WORKDIR	/var/www/html

# Renaming to 'index.php' as php command checks for that file by default
# COPY	./tools/adminer-5.4.1-en.php index.php

RUN		wget "https://www.adminer.org/latest-en.php" -O index.php

EXPOSE	8080

# Start Adminer script via PHP built-in server (runs index.php by default)
CMD		["php", "-S", "[::]:8080"]
