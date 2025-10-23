#!/bin/sh

# Wait for WordPress PHP-FPM to be available
echo "Waiting for WordPress PHP-FPM (wordpress:9000) to start..."

# Loop until netcat (nc) successfully connects (-z) to the wordpress service on port 9000
while ! nc -z wordpress 9000; do
	sleep 1
done
echo "WordPress PHP-FPM is available."

# Wait for Redis Explorer PHP-FPM to be available
echo "Waiting for Redis Explorer PHP-FPM (redis-explorer:9000) to start..."
while ! nc -z redis-explorer 9000; do
	sleep 1
done
echo "Redis Explorer PHP-FPM is available."

echo "All services are up. Starting Nginx..."

# Execute the main Nginx command (the CMD)
exec "$@"
