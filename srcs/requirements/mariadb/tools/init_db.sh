#!/bin/sh

# 'set -e' makes the script exit immediately if any command fails.
set -e

# Read the password content from the mounted secret files:
DB_ROOT_PASSWORD=$(cat $DB_ROOT_PASSWORD_FILE)
DB_USER_PASSWORD=$(cat $DB_USER_PASSWORD_FILE)

# Check if the database data directory is empty.
# If it's not empty, it means initialization has already run.
if [ -d "$DB_VOLUME/$DB_NAME" ]; then		# '-d' returns true if argument exists and is a directory
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
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';

		-- Create the main database for WordPress.
		CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;

		-- Create a dedicated user for WordPress to connect with.
		CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';

		-- Grant that user full permissions on the WordPress database only.
		GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

		-- Apply all the privilege changes.
		FLUSH PRIVILEGES;
	EOF

	# This is the key command. 'mariadbd --bootstrap' runs the server
	# just long enough to execute the SQL from the file, then it exits.
	# This initializes the database data directory ($DB_VOLUME: /var/lib/mysql) correctly.
	mariadbd --bootstrap < $init

	# The bootstrap process creates files owned by root. We must change ownership
	# to the 'mysql' user, which is what the final server process runs as.
	echo "Setting correct file permissions..."
	chown -R mysql:mysql $DB_VOLUME

	# Clean up the temporary file.
	rm -f $init

	echo "MariaDB database and user setup complete."
fi

# 'exec "$@"' passes control to the CMD specified in the Dockerfile
# (which is 'mysqld_safe'). This starts the MariaDB server in the foreground,
# keeping the container running.
echo "Starting MariaDB server in the foreground..."
exec "$@" # expands to all arguments passed to the script (the commands after the entrypoint in the Dockerfile) -> 'exec mysqld_safe'
