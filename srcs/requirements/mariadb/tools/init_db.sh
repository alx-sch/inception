#!/bin/bash
set -e

# Check if the 'mysql' database directory exists as a sign of initialization
if [ -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDB is already initialized. Skipping setup."
else
    echo "Initializing MariaDB for the first time..."

    # 1. Initialize the data directory. This creates the system tables.
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # 2. Start a temporary server in the background.
    #    --skip-networking makes sure it's only accessible locally.
    mysqld_safe --datadir='/var/lib/mysql' --skip-networking &
    
    # 3. Wait for the server to be ready for connections.
    until mysqladmin ping --silent; do
        echo -n "."; sleep 1
    done
    echo "Temporary MariaDB server is up."

    # 4. Run your SQL commands using the standard client.
    mariadb <<-EOF
        -- Set a password for the root user.
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        
        -- Create the WordPress database.
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        
        -- Create the WordPress user and grant it permissions.
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        
        -- Apply the changes.
        FLUSH PRIVILEGES;
EOF

    # 5. Stop the temporary server.
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    echo "Initialization complete. Temporary server stopped."
fi

# This is the crucial final step. It runs the CMD from your Dockerfile
# ("mysqld_safe") as the main process of the container.
echo "Starting MariaDB server for external connections..."
exec "$@"
