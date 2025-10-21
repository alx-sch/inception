# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM		debian:bookworm-slim

# Author & Maintainer
LABEL		maintainer="aschenk"

# Update package lists and install necessary packages.
# - We remove package lists afterwards to keep the final image size smaller.
RUN			apt-get update && apt-get install -y \
			mariadb-server \
			mariadb-client \
			&& rm -rf /var/lib/apt/lists/*

# Copy the MariaDB configuration file and set permissions (gets rid of warnings in the logs).
# This file allows connections from other containers (like WordPress).
COPY		./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN			chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the entrypoint script to initialize the database and make it executable.
COPY		./tools/init_db.sh /usr/local/bin/init_db.sh
RUN			chmod +x /usr/local/bin/init_db.sh

# Document MariaDB default port
EXPOSE		3306

# Set the entrypoint for the container.
# This script will run when the container starts, setting up the database.
ENTRYPOINT	["/usr/local/bin/init_db.sh"]

# The default command to run when the entrypoint script finishes its setup,
# starting the MariaDB server that listens for incoming connections.
# 'mysqld_safe' is a wrapper that restarts the MariaDB server if it crashes.
# It also keeps the database running in the foreground (even though a daemon is called -> mysql'd'),
# keeping the container alive.
# JUST FYI: 'mysqld' starts the actual database server program,
# while 'mysql' is the command-line client used to interact with the server.
CMD			["mysqld_safe"]
