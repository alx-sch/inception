# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM	debian:bookworm-slim

# Author & Maintainer
LABEL	maintainer="aschenk"

# Install necessary packages: PHP, PHP-FPM, PHP-MySQL extension, and utilities
# - pure-ftpd-common: Dependency package for Pure-FTPd
# - pure-ftpd: The actual FTP server software
RUN		apt-get update && apt-get install -y --no-install-recommends \
		pure-ftpd-common \
		pure-ftpd \
		netcat \
		&& rm -rf /var/lib/apt/lists/*

# Create a dedicated, non-root user 'ftpuser' with UID/GID 33 to match 'www-data' (default web server user)
RUN		groupadd -g 33 ftpuser && \
		useradd -u 33 -g ftpuser -d /home/ftpuser ftpuser && \
		mkdir -p /home/ftpuser/www/html && \
		chown -R 33:33 /home/ftpuser

# The default command runs Pure-FTPd with configuration options.
# -A: No anonymous logins allowed
# -C: Limits number of connections per IP (10 here)
# -p 21000:21009: Defines the passive port range
# -P 0.0.0.0: External IP address for passive mode (0.0.0.0 means all interfaces)
# -r: chroots users to their home directory (security)
CMD ["pure-ftpd", "-A", "-C 10", "-p 21000:21009", "-P", "0.0.0.0", "-r"]
