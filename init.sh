#!/bin/bash

# Logging function to echo output with a timestamp
log() {
    echo "[$(date '+%m/%d/%y %H:%M:%S')] $1"
}

# Update NGINX configuration with the desired port
if [ "$WEB_UI_PORT" != "6565" ]; then
    log "Updating NGINX configuration to use port $WEB_UI_PORT..."
fi
sed -i "s/__PORT__/$WEB_UI_PORT/g" /etc/nginx/sites-available/default

# Check if http basic auth user/password env var are configured
if [ "$WEB_UI_USER" ] && [ "$WEB_UI_PASSWORD" ]; then
    log "Setting up HTTP Basic Authentication for NGINX..."
    htpasswd -bc /etc/nginx/.htpasswd "$WEB_UI_USER" "$WEB_UI_PASSWORD"
    sed -i 's/# auth/auth/g' /etc/nginx/sites-available/default
fi

# Start NGINX server
log "Starting NGINX server..."
nginx > >(while IFS= read -r line; do log "$line"; done) 2>&1 &

# Output current nicotine user UID/GID for awareness
log "The current nicotine UID/GID is:"
log "$(id nicotine)"

# Define and change UID/GID, and WebUI port
PUID=${PUID:-1000}
PGID=${PGID:-1000}
WEB_UI_PORT=${WEB_UI_PORT:-6565}

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

# Ensure correct ownership of config and data directories
log "Ensuring correct ownership of config and data directories..."
chown -R nicotine:nicotine /config /data /home/nicotine/.config /home/nicotine/.local 2>/dev/null || true

# Ensure cache directory exists with correct permissions for Broadway socket
mkdir -p /home/nicotine/.cache
chown nicotine:nicotine /home/nicotine/.cache
chmod 755 /home/nicotine/.cache

# Set the timezone if TZ is provided
if [ -n "${TZ}" ]; then
    if [ -f "/usr/share/zoneinfo/${TZ}" ]; then
        ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
        echo "${TZ}" > /etc/timezone
        log "Timezone set to ${TZ}"
        log "Current time: $(date)"
    else
        log "Invalid timezone: ${TZ}. Falling back to UTC."
        ln -sf "/usr/share/zoneinfo/UTC" /etc/localtime
        echo "UTC" > /etc/timezone
    fi
else
    log "Time zone not set, using default (UTC)"
    log "Current time: $(date)"
fi

if [ -n "${LANG}" ]; then
    # Add locale to system config
    echo "${LANG} UTF-8" >> /etc/locale.gen
    
    # Run locale-gen and log the output
    if locale-gen "${LANG}" > /tmp/locale_gen_output.log 2>&1; then
        # Update environment with locale
        echo "LANG=${LANG}" > /etc/locale.conf
        echo -e "LANG=${LANG}\nLC_ALL=${LANG}\nLANGUAGE=${LANG}" > /etc/environment
    else
        log "Failed to generate locale for ${LANG}"
    fi
    
    # Log the output
    while IFS= read -r line; do log "$line"; done < /tmp/locale_gen_output.log
else
    log "Locale not specified, using default (C.UTF-8)"
fi

# Start the DBus session (if needed) and export the result
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Hand off to the nicotine user, keeping the current environment
exec env HOME="/home/nicotine" su --preserve-environment nicotine -c "/usr/local/bin/launch.sh"
