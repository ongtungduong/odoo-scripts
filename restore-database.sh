#!/bin/bash

# Set the script to stop on any errors
set -e

# Set value for parameters
REPLACE='true'
ODOO_HOST="https://odoo.host"
PASSWORD="password"
DATABASE="database"
FILE="/var/tmp/database.zip"

# Install curl and unzip if needed
packages=(curl unzip)
for package in "${packages[@]}"
  do
    if ! [ -x "$(command -v "$package")" ]; then
        sudo apt install -y "$package"
    fi
  done

# Validate zip file
unzip -q -t $FILE

# Replace existing database if REPLACE='true'
if $REPLACE; then
  curl \
    --silent \
    -F "master_pwd=${PASSWORD}" \
    -F "name=${DATABASE}" \
    ${ODOO_HOST%/}/web/database/drop | grep -q -E 'Internal Server Error|Redirecting...'
fi

# Request database restore
CURL=$(curl \
  -F "master_pwd=$PASSWORD" \
  -F "name=$DATABASE" \
  -F backup_file=@$FILE \
  -F 'copy=true' \
  "${ODOO_HOST%/}/web/database/restore")

# Check for errors
(echo $CURL | grep -q 'Redirecting...') || (echo "Restore database failed:"; echo $CURL | grep error; exit 1)

# Announce restore completed
echo "Restore database $DATABASE completed"