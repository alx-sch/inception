#!/bin/bash
set -e

# Read FTP password from secret file, strip any trailing newline
FTP_USER_PASSWORD=$(cat $FTP_USER_PASSWORD_FILE)

# Wait until the WordPress volume is mounted
while [ ! -d "$WP_VOLUME" ]; do
	echo "Waiting for WordPress volume $WP_VOLUME..."
	sleep 1
done

# Create the user if they don't exist
if ! id -u "$FTP_USER" > /dev/null 2>&1; then
	echo "User '$FTP_USER' not found, creating..."
	# Create a user with no password login, set their home dir, and no shell
	adduser --disabled-password --gecos "" --home "$WP_VOLUME" "$FTP_USER"
fi

# Set the user's password
echo "$FTP_USER:$FTP_USER_PASSWORD" | chpasswd

# Give ownership of the home directory to the user
chown "$FTP_USER":"$FTP_USER" "$WP_VOLUME"
echo "FTP setup complete. Starting vsftpd..."

# Execute vsftpd server
/usr/sbin/vsftpd /etc/vsftpd.conf
