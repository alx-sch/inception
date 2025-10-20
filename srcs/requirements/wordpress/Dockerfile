# Base image for the container.
# Debian 12 ("Bookworm") is the latest stable version currenly, but
# Debian 11 ("Bullseye") is the current penultimate stable version.
FROM		debian:bullseye-slim

# Author & Maintainer
LABEL		maintainer="aschenk"

# Update package lists and install all necessary packages in a single layer.
# - php-fpm: The PHP FastCGI Process Manager, which runs the WordPress code -> is 7.4 in Debian Bullseye
# - php-mysql: The extension that allows PHP to communicate with MariaDB.
# - curl: A utility for downloading files from the internet.
# - netcat-traditional: Used in entrypoint script to check if database port is open/ready.
# We clean up apt cache and lists to keep the final image size smaller.
RUN			apt-get update && apt-get install -y \
			php-fpm \
			php-mysql \
			curl \
			netcat-traditional \
			&& rm -rf /var/lib/apt/lists/*

# Download the WordPress Command-Line Interface (wp-cli).
# This is the primary tool we will use in our script to automate the setup.
# 'curl' downloads the file and '-o' specifies the output path and filename.
# We then make the script executable.
# https://wp-cli.org/#installing for more details.
RUN			curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
			&& chmod +x /usr/local/bin/wp

# Create the main directory for the WordPress files; that's also the default web root for most web servers (NGINX).
# The '-p' flag creates parent directories if they don't exist.
RUN			mkdir -p /var/www/html

# Change the working directory. All subsequent commands will run from here.
WORKDIR		/var/www/html

# Download WordPress core files (specific version for stability).
# Using 'wp core download' is a clean way to get the files without extra directories.
# '--allow-root' is necessary because we are running as the root user inside the Docker build.
# Use the most recent version of the latest "finished" branch (currently 6.7): https://wordpress.org/download/releases/
RUN			wp core download --version=6.7.3 --allow-root

# Create the directory that PHP-FPM needs to run (standard location).
RUN			mkdir -p /run/php

# Copy in a custom configuration file for PHP-FPM
COPY		./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy the entrypoint script and make it executable
COPY		./tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN			chmod +x /usr/local/bin/init_wp.sh

# Set the entrypoint to run the setup script first.
ENTRYPOINT	["/usr/local/bin/init_wp.sh"]

# Start the PHP FastCGI Process Manager in the foreground
# CMD calls 'exec' style --> looks for the binary in the $PATH
# '-F' flag tells php-fpm to run in the foreground (not as a daemon)
CMD			["php-fpm7.4", "-F"]
