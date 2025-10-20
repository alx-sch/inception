# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM		debian:bookworm-slim

# Author & Maintainer
LABEL		maintainer="aschenk"

# Install necessary packages: PHP, PHP-FPM, PHP-MySQL extension, and utilities
RUN		apt-get update && apt-get install -y --no-install-recommends \
		redis-server \
		&& rm -rf /var/lib/apt/lists/*

WORKDIR	/var/www/html

# Start Redis server
CMD ["redis-server"]
