#!/bin/bash

# Just for logging, so logs are not empty for the redis container
echo "Starting Redis server..."

exec "$@"
