#!/bin/bash
set -e

# Define the web group server group (standard for Debian/Ubuntu)
WEB_GROUP="www-data"
WEB_USER="www-data"

# Read FTP password from secret file, strip any trailing newline
FTP_USER_PASSWORD=$(cat $FTP_USER_PASSWORD_FILE)

# Wait until the WordPress volume is mounted
while [ ! -d "$WP_VOLUME" ]; do
	echo "Waiting for WordPress volume $WP_VOLUME..."
	sleep 1
done

# Create the web group if it doesn't exist (should exist already)
if ! getent group "$WEB_GROUP" >/dev/null; then
	echo "Group '$WEB_GROUP' not found, creating..."
	groupadd "$WEB_GROUP"
else
	echo "Group '$WEB_GROUP' already exists."
fi

# Create the FTP user with a distinct UID (2000) and add them to the www-data group.
if ! id -u "$FTP_USER" > /dev/null 2>&1; then
	echo "User '$FTP_USER' creating and adding to $WEB_GROUP..."
	# Assign UID 2000 to avoid conflict with host's UID 1000
	adduser --uid 2000 --disabled-password --gecos "" --home "$WP_VOLUME" --ingroup "$WEB_GROUP" "$FTP_USER"
else
	echo "User '$FTP_USER' already exists. Adding to group '$WEB_GROUP' if not already a member."
	# Ensure the user is in the web group
	usermod -aG "$WEB_GROUP" "$FTP_USER"
fi

# Set the user's password
echo "$FTP_USER:$FTP_USER_PASSWORD" | chpasswd

## Set Web-centric Permissions on the WordPress Volume ##

echo "Setting ownership to $WEB_USER:$WEB_GROUP for consistency..."

# Set ownership of the whole volume to www-data:www-data
chown -R "$WEB_USER":"$WEB_GROUP" "$WP_VOLUME"

# Set directory permissions to 2775 (rwxrwsr-x)
# The '2' (SETGID) ensures new files/folders are always owned by the www-data group.
find "$WP_VOLUME" -type d -exec chmod 2775 {} \;

# Set file permissions to 0664 (rw-rw-r--)
# Allows both www-data (Owner) and www-data (Group member: ftp_user) to write.
find "$WP_VOLUME" -type f -exec chmod 0664 {} \;

# Restore secure permissions for wp-config.php (rw-r--r--)
chmod 644 "$WP_VOLUME/wp-config.php"

echo "FTP setup complete. Starting vsftpd..."

# Execute vsftpd server
/usr/sbin/vsftpd /etc/vsftpd.conf
