#!/bin/bash

# Set the script to stop on any errors
set -e

# Set value for parameters
ODOO_HOST="https://odoo.host"
PASSWORD="password"
DATABASE="database"
FILE="$DATABASE.zip"
OUTPUT="/var/tmp"
FILEPATH="${OUTPUT}/${FILE}"

# Install curl and unzip if needed
packages=(curl unzip)
for package in "${packages[@]}"
  do
    if ! [ -x "$(command -v "$package")" ]; then
        sudo apt install -y "$package"
    fi
  done

# Request database backup and save to filepath
echo "Requesting backup of $DATABASE to $FILEPATH"
curl -X POST \
  -F "master_pwd=$PASSWORD" \
  -F "name=$DATABASE" \
  -F "backup_format=zip" \
  -o "$FILEPATH" \
  "$ODOO_HOST/web/database/backup"

# Check for errors
FILETYPE="$(file --mime-type -b "$FILEPATH")"
if [[ "$FILETYPE" == 'text/html' ]]; then
  grep error "$FILEPATH"
fi
echo "Validating $FILEPATH"
unzip -q -t "$FILEPATH"

# Announce backup completed
echo "Backup completed: $FILEPATH"
