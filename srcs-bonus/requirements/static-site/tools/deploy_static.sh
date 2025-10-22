#!/bin/bash
set -e

echo "Deploying static site to volume..."

DEPLOY_SOURCE="/site-files-temp"
DEPLOY_TARGET="$WP_VOLUME/$STATIC_SITE"

WEB_USER="www-data"

# Clean up and create the target directory on the volume
rm -rf $DEPLOY_TARGET/*
mkdir -p $DEPLOY_TARGET

# Copy the files from the temporary build location to the mounted volume
cp -a $DEPLOY_SOURCE/. $DEPLOY_TARGET/

# Remove local files to save space
rm -rf $DEPLOY_SOURCE/*

# Fix ownership and permissions for the web server
chown -R $WEB_USER:$WEB_USER $DEPLOY_TARGET
chmod -R 755 $DEPLOY_TARGET

echo "Static site deployment complete."
