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

# Export environment variables
export GDK_BACKEND=broadway
export BROADWAY_DISPLAY=:5
export NICOTINE_GTK_VERSION=4
export NO_AT_BRIDGE=1

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
sed -i "s/login =.*/login = ${LOGIN:-}/g" "$CONFIG_FILE"
sed -i "s/passw =.*/passw = ${PASSW:-}/g" "$CONFIG_FILE"
sed -i "s/upnp =.*/upnp = ${UPNP:-}/g" "$CONFIG_FILE"
sed -i "s/notification_popup_file =.*/notification_popup_file = ${NOTIFY_FILE:-}/g" "$CONFIG_FILE"
sed -i "s/notification_popup_folder =.*/notification_popup_folder = ${NOTIFY_FOLDER:-}/g" "$CONFIG_FILE"
sed -i "s/notification_window_title =.*/notification_window_title = ${NOTIFY_TITLE:-}/g" "$CONFIG_FILE"
sed -i "s/notification_popup_private_message =.*/notification_popup_private_message = ${NOTIFY_PM:-}/g" "$CONFIG_FILE"
sed -i "s/notification_popup_chatroom =.*/notification_popup_chatroom = ${NOTIFY_CHATROOM:-}/g" "$CONFIG_FILE"
sed -i "s/notification_popup_chatroom_mention =.*/notification_popup_chatroom_mention = ${NOTIFY_MENTION:-}/g" "$CONFIG_FILE"
sed -i "s/trayicon =.*/trayicon = ${TRAY_ICON:-}/g" "$CONFIG_FILE"
sed -i "s/auto_connect_startup =.*/auto_connect_startup = ${AUTO_CONNECT:-}/g" "$CONFIG_FILE"

# Set GTK theme if DARKMODE is enabled
shopt -s nocasematch

if [[ -n "${DARKMODE}" ]]; then
    if [[ "${DARKMODE}" == "False" ]]; then
        sed -i "s/dark_mode =.*/dark_mode = False/g" "$CONFIG_FILE"
    else
        sed -i "s/dark_mode =.*/dark_mode = True/g" "$CONFIG_FILE"
    fi
else
    log "DARKMODE not set, using default (dark)."
    sed -i "s/dark_mode =.*/dark_mode = True/g" "$CONFIG_FILE"
fi

shopt -u nocasematch

# Start the DBus session
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

log "Starting Nicotine+..."
exec nicotine --isolated 2> >(grep -v "Broken accounting")
