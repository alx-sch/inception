# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM	debian:bookworm-slim

# Author & Maintainer
LABEL	maintainer="aschenk"

# Install necessary packages: PHP, PHP-FPM, PHP-MySQL extension, and utilities
RUN		apt-get update && apt-get install -y --no-install-recommends \
		redis-server \
		&& rm -rf /var/lib/apt/lists/*

# Redis runs on port 6379 by default
EXPOSE	6379

# Modify the configuration file to listen on all interfaces (0.0.0.0)
# This allows WordPress and other services to connect using the Docker network.
# sed -i -> search and replace in-place
RUN sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf

# Command to start the Redis server in the foreground, using the updated config.
CMD ["redis-server", "/etc/redis/redis.conf", "--protected-mode", "no", "--daemonize", "no"]
