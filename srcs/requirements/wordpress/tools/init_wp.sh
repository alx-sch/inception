#!/bin/sh

# Sources:
# https://www.hostpress.de/blog/wp-config-erstellen-finden-bearbeiten/
# https://developer.wordpress.org/cli/commands/config/create/
# https://www.catalyst2.com/knowledgebase/wp-cli/installing-wordpress-using-wp-cli/

# 'set -e' makes the script exit immediately if any command fails.
set -e

# Read the password content from the mounted secret files:
DB_USER_PASSWORD=$(cat $DB_USER_PASSWORD_FILE)
WP_ADMIN_PASSWORD=$(cat $WP_ADMIN_PASSWORD_FILE)
WP_USER_PASSWORD=$(cat $WP_USER_PASSWORD_FILE)

# --- WAIT FOR DATABASE ---
echo "Checking database readiness at $DB_HOST:$DB_PORT..."

# This loop uses netcat to check if the port is open ('-z' flag is for scanning, no data sent).
while ! nc -z $DB_HOST $DB_PORT; do
	sleep 1
done
echo "Database is connected."

# --- WP-CONFIG.PHP GENERATION ---
# Check if wp-config.php exists. If not, create it using env variables.
if [ ! -f "$WP_VOLUME/wp-config.php" ]; then
	echo "Creating wp-config.php..."
	wp config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_USER_PASSWORD" \
		--dbhost="$DB_HOST:$DB_PORT" \
		--allow-root \
		--skip-check \
		--path="$WP_VOLUME"
fi

# --- WORDPRESS INSTALLATION ---
# Check if WordPress tables are created. If not, run the core installation.

export HTTP_HOST=$DOMAIN_NAME # Set HTTP_HOST for wp-cli to use in installation URL (avoids warning).

if ! wp core is-installed --allow-root --path="$WP_VOLUME"; then
	echo "Installing WordPress core..."
	wp core install \
		--url="https://$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email \
		--allow-root \
		--path="$WP_VOLUME"
fi

# --- DISABLE COMMENT MODERATION SETTINGS ---
# makes comments appear immediately (very optional)
echo "Disabling comment moderation settings..."
wp option update comment_moderation 0 --allow-root --path="$WP_VOLUME" && \
wp option update comment_whitelist 0 --allow-root --path="$WP_VOLUME" && \

# --- CREATE USER OTHER THAN ADMIN ---
if ! wp user get "$WP_USER" --allow-root --path="$WP_VOLUME" > /dev/null 2>&1; then
	echo "Creating WordPress user '$WP_USER'..."
	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--role=editor \
		--user_pass="$WP_USER_PASSWORD" \
		--allow-root \
		--path="$WP_VOLUME"
fi

# --- SET FILE PERMISSIONS ---
# Change ownership of all WordPress files to the www-data user/group.
# This is necessary because files were created by root (via --allow-root).
# 'www-data' is the default user for PHP-FPM and web server processes on Debian-based systems.
echo "Setting file permissions for www-data..."
chown -R www-data:www-data "$WP_VOLUME"

# --- START MAIN PROCESS ---
echo "Setup complete. Starting PHP-FPM in foreground..."
# Execute the command passed via CMD (which is /usr/sbin/php-fpm8.2 -F)
exec "$@"
