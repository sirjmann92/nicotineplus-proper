#!/bin/bash

# Logging function to echo output with a timestamp
log() {
    echo "[$(date '+%m/%d/%y %H:%M:%S')] $1"
}

# Check if UMASK is defined and set it
if [ -n "${UMASK}" ]; then
    log "Setting UMASK to ${UMASK}"
    umask "${UMASK}"
else
    log "UMASK not set, using default (022)"
    umask 022
fi

# Check if plugins directory exists, create it if not 
if [ ! -d "/data/plugins" ]; then
    mkdir -p /data/plugins
    log "Created plugins directory..."
    touch /data/plugins/place_custom_plugins_here
else
    log "Plugins directory exists, skipping setup..."
fi

# Start Broadway daemon and log output
log "Starting Broadway daemon..."
gtk4-broadwayd :5 > >(while IFS= read -r line; do log "$line"; done) 2>&1 &

# Define config file paths
CONFIG_FILE="/home/nicotine/.config/nicotine/config"
CONFIG_DEFAULT="/home/nicotine/config-default"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log "Configuration file not found"
    log "Importing default configuration..." 
    cp "$CONFIG_DEFAULT" "$CONFIG_FILE" || { echo "Failed to import default configuration. Exiting..."; exit 1; }
fi

# Update config file with environment variables
sed -i "s/login =.*/login = ${LOGIN:-}/" "$CONFIG_FILE"
sed -i "s/passw =.*/passw = ${PASSW:-}/" "$CONFIG_FILE"
sed -i "s/upnp =.*/upnp = ${UPNP:-}/" "$CONFIG_FILE"
sed -i "s/notification_popup_file =.*/notification_popup_file = ${NOTIFY_FILE:-}/" "$CONFIG_FILE"
sed -i "s/notification_popup_folder =.*/notification_popup_folder = ${NOTIFY_FOLDER:-}/" "$CONFIG_FILE"
sed -i "s/notification_window_title =.*/notification_window_title = ${NOTIFY_TITLE:-}/" "$CONFIG_FILE"
sed -i "s/notification_popup_private_message =.*/notification_popup_private_message = ${NOTIFY_PM:-}/" "$CONFIG_FILE"
sed -i "s/notification_popup_chatroom =.*/notification_popup_chatroom = ${NOTIFY_CHATROOM:-}/" "$CONFIG_FILE"
sed -i "s/notification_popup_chatroom_mention =.*/notification_popup_chatroom_mention = ${NOTIFY_MENTION:-}/" "$CONFIG_FILE"
sed -i "s/trayicon =.*/trayicon = ${TRAY_ICON:-}/" "$CONFIG_FILE"
sed -i "s/auto_connect_startup =.*/auto_connect_startup = ${AUTO_CONNECT:-}/" "$CONFIG_FILE"

# Set GTK theme if DARKMODE is enabled
shopt -s nocasematch

if [[ -n "${DARKMODE}" ]]; then
    if [[ "${DARKMODE}" == "False" ]]; then
        sed -i "s/dark_mode =.*/dark_mode = False/" "$CONFIG_FILE"
    else
        sed -i "s/dark_mode =.*/dark_mode = True/" "$CONFIG_FILE"
    fi
else
    log "DARKMODE not set, using default (dark)."
    sed -i "s/dark_mode =.*/dark_mode = True/" "$CONFIG_FILE"
fi

shopt -u nocasematch

# Check if FORWARD_PORT is set and update config file
if [[ -n "$FORWARD_PORT" ]]; then
    # Only replace portrange if the env var is explicitly set
    sed -i "s/^portrange =.*/portrange = (${FORWARD_PORT}, ${FORWARD_PORT})/" "$CONFIG_FILE"
    log "Listening port updated. Now listening on port: ${FORWARD_PORT}"
else
    log "FORWARD_PORT not set, leaving existing portrange unchanged."
fi

# Start the DBus session
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Start Nicotine+ in isolated mode, filter harmless messages
log "Starting Nicotine+..."
exec nicotine --isolated 2> >(
    grep -v "Broken accounting" |
    grep -v "GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER"
)
