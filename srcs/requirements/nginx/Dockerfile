# Base image for the container.
# Debian 12 ("Bookworm") is the latest stable version currently, but
# Debian 11 ("Bullseye") is the current penultimate stable version.
FROM		debian:bullseye

# Author
LABEL		author="aschenk"

# Update package lists and install Nginx in a single layer.
# - nginx: The web server software.
# We clean up apt cache and lists to keep the final image size smaller.
RUN			apt-get update && apt-get install -y \
			nginx \
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

# '-g daemon off;' tells Nginx to run in the foreground (not as a daemon) -> Container keeps running
CMD			["nginx", "-g", "daemon off;"]
