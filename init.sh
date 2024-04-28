#!/bin/bash

# Logging function to echo output with a timestamp
log() {
    echo "[$(date '+%m/%d/%y %H:%M:%S')] $1"
}

# Output current nicotine user UID/GID for awareness
log "The current nicotine UID/GID is:"
log "$(id nicotine)"

# Define and change UID/GID
PUID=${PUID:-1000}
PGID=${PGID:-1000}

changed=false

if [ "$PUID" != "1000" ]; then
    log "Changing nicotine user UID to $PUID"
    usermod -o -u "$PUID" nicotine
    changed=true
fi

if [ "$PGID" != "1000" ]; then
    log "Changing nicotine user GID to $PGID"
    groupmod -o -g "$PGID" nicotine
    changed=true
fi

if [ "$changed" = true ]; then
    log "The nicotine user UID/GID has been changed to:"
    log "$(id nicotine)"
fi

# Start NGINX server
log "Starting NGINX server..."
nginx > >(while IFS= read -r line; do log "$line"; done) 2>&1 &

nginx_pid=$!

# Run Nicotine+ launch script as nicotine user
su -c "/usr/local/bin/launch.sh" nicotine
