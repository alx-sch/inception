# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM		debian:bookworm-slim

# Author & Maintainer
LABEL		maintainer="aschenk"

# Update package lists and install Nginx in a single layer.
# - nginx: The web server software.
# - netcat-traditional: Used in entrypoint script to check if wordpress:9000 is open/ready.
# We clean up apt cache and lists to keep the final image size smaller.
RUN			apt-get update && apt-get install -y \
			nginx \
			netcat-traditional \
			&& rm -rf /var/lib/apt/lists/*

# Create directories for SSL files.
RUN			mkdir -p /etc/nginx/ssl

# Copy the SSL Certificate and Key from the host into the container
COPY		./conf/ssl/inception.crt /etc/ssl/certs/inception.crt
COPY		./conf/ssl/inception.key /etc/ssl/private/inception.key

# Copy the config file
COPY		./conf/default.conf /etc/nginx/conf.d/default.conf

# Remove the default Nginx configuration file
RUN			rm /etc/nginx/sites-enabled/default

# Expose the standard HTTPS port 443.
EXPOSE		443

# Copy the custom startup script and make it executable
COPY		./tools/wait-start.sh /usr/local/bin/wait-start.sh
RUN			chmod +x /usr/local/bin/wait-start.sh

# Set the entrypoint to run the wait script first.
ENTRYPOINT  ["/usr/local/bin/wait-start.sh"]

# '-g daemon off;' tells Nginx to run in the foreground (not as a daemon) -> Container keeps running
CMD			["nginx", "-g", "daemon off;"]
