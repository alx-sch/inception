# Base image for the container.
# Debian 12 ("Bookworm") is the latest stable version currenly, but
# Debian 11 ("Bullseye") is the current penultimate stable version.
FROM		debian:bullseye

# Author
LABEL		author="aschenk@student.42berlin.de"

# Update package lists and install necessary packages.
# - We remove package lists afterwards to keep the final image size smaller.
RUN			apt-get update && apt-get install -y \
			mariadb-server \
			mariadb-client \
			&& rm -rf /var/lib/apt/lists/*

# Copy the MariaDB configuration file.
# This file allows connections from other containers (like WordPress).
COPY		./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the entrypoint script to initialize the database.
COPY		./tools/initial_db.sh /usr/local/bin/initial_db.sh

# Make the entrypoint script executable.
RUN			chmod +x /usr/local/bin/initial_db.sh

# Expose the default MariaDB port (3306) to allow connections from other containers.
EXPOSE		3306

# Set the entrypoint for the container.
# This script will run when the container starts, setting up the database.
ENTRYPOINT	["/usr/local/bin/initial_db.sh"]

# The default command to run when the entrypoint script finishes its setup,
# starting the MariaDB server that listens for incoming connections.
# 'mysqld_safe' is a wrapper that restarts the MariaDB server if it crashes.
CMD			["mysqld_safe"]
