# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM	debian:bookworm-slim

# Author & Maintainer
LABEL	maintainer="aschenk"

# Set non-interactive mode for apt operations
ENV		DEBIAN_FRONTEND=noninteractive

# Install Redis Server
# -php-fpm: To run PHP Redis Explorer script
# -php-redis: PHP extension to interact with Redis
RUN		apt-get update && \
		apt-get install -y --no-install-recommends \
		php8.2-fpm \
		php8.2-redis \
		&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the directory that PHP-FPM needs to run (standard location).
RUN		mkdir -p /run/php

# The configuration file sets PHP-FPM to listen on TCP port 9000.
COPY	./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy the Redis Explorer PHP script into the container's web root
COPY	./tools/redis_explorer.php /var/www/redis_explorer.php

# Document PHP-FPM default port (internal)
EXPOSE	9000

# Command to start the PHP FastCGI Process Manager in the foreground
# This keeps the container alive and ready to process requests from Nginx.
CMD		["php-fpm8.2", "-F"]
