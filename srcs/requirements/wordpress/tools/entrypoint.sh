#!/bin/sh

# Sources:
# https://www.hostpress.de/blog/wp-config-erstellen-finden-bearbeiten/
# https://developer.wordpress.org/cli/commands/config/create/
# https://www.catalyst2.com/knowledgebase/wp-cli/installing-wordpress-using-wp-cli/

# 'set -e' makes the script exit immediately if any command fails.
set -e

# Load the file paths from the container's environment (as set in docker-compose.yml):
DB_PASSWORD_F=$DB_PASSWORD_FILE
WP_ADMIN_PASSWORD_F=$WP_ADMIN_PASSWORD_FILE

# Read the password content from the mounted secret files:
DB_PASSWORD=$(cat $DB_PASSWORD_F)
WP_ADMIN_PASSWORD=$(cat $WP_ADMIN_PASSWORD_F)

# The paths below are set via environment variables in docker-compose.yml
DB_PASSWORD_FILE=/run/secrets/db_password
WP_ADMIN_PASSWORD_FILE=/run/secrets/wp_admin_password

DB_PASSWORD=$(cat $DB_PASSWORD_FILE)
WP_ADMIN_PASSWORD=$(cat $WP_ADMIN_PASSWORD_FILE)

# --- 1. WAIT FOR DATABASE ---
echo "Waiting for database readiness at $DB_HOST:$DB_PORT..."

# This loop uses netcat to check if the port is open ('-z' flag is for scanning, no data sent).
while ! nc -z $DB_HOST $DB_PORT; do
	sleep 1
done
echo "Database is ready."


# --- 2. WP-CONFIG.PHP GENERATION ---
# Check if wp-config.php exists. If not, create it using env variables.
if [ ! -f "$WP_PATH/wp-config.php" ]; then
	echo "Creating wp-config.php..."
	wp config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST" \
		--allow-root \
		--skip-check \
		--path="$WP_PATH"
fi


# --- 3. WORDPRESS INSTALLATION ---
# Check if WordPress tables are created. If not, run the core installation.
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
	echo "Installing WordPress core..."
	wp core install \
		--url="https://$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email \
		--allow-root \
		--path="$WP_PATH"

		echo "WordPress setup complete."
fi

# --- 4. START MAIN PROCESS ---
echo "Starting PHP-FPM..."
# Execute the command passed via CMD (which is /usr/sbin/php-fpm7.4 -F)
exec "$@"
