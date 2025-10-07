#!/bin/bash

# This script runs when the MariaDB container starts.
# It sets up the database and user with the credentials
# provided in the docker-compose.yml file.

# 'set -e' will make the script exit immediately if any command fails.
set -e

# We check if the database data directory is empty.
# If it's not empty, it means initialization has already run.
if [ -d "/var/lib/mysql/$DB_NAME" ]; then		# '-d' returns true if argument exists and is a directory
	echo "Database '$DB_NAME' already exists. Skipping initialization."
else
	echo "Initializing MariaDB database..."

	# Create a temporary file to hold our SQL commands.
	# Using 'mktemp' is safer than just creating a file with a fixed name.
	init=`mktemp`
	if [ ! -f "$init" ]; then
		return 1
	fi

	# Write all our SQL setup commands into the temporary file.
	# This is safer and more reliable than piping to the mysql client.
	cat <<-EOF > $init
		-- This command ensures the grant tables are reloaded.
		FLUSH PRIVILEGES;

		-- Set the password for the root user.
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/root_password)';

		-- Create the main database for WordPress.
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

		-- Create a dedicated user for WordPress to connect with.
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';

		-- Grant that user full permissions on the WordPress database only.
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

		-- Apply all the privilege changes.
		FLUSH PRIVILEGES;
	EOF

	# This is the key command. 'mariadbd --bootstrap' runs the server
	# just long enough to execute the SQL from the file, then it exits.
	# This initializes the database data directory (/var/lib/mysql) correctly.
	mariadbd --bootstrap < $init

	# The bootstrap process creates files owned by root. We must change ownership
	# to the 'mysql' user, which is what the final server process runs as.
	echo "Setting correct file permissions..."
	chown -R mysql:mysql /var/lib/mysql

	# Clean up the temporary file.
	rm -f $init

	echo "MariaDB database and user setup complete."
fi

# 'exec "$@"' passes control to the CMD specified in the Dockerfile
# (which is 'mysqld_safe'). This starts the MariaDB server in the foreground,
# keeping the container running.
echo "Starting MariaDB server in the foreground..."
exec "$@" # expands to all arguments passed to the script (the commands after the entrypoint in the Dockerfile) -> 'exec mysqld_safe'
