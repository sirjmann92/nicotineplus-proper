#!/bin/bash

# Logging function to echo output with a timestamp
log() {
    echo "[$(date '+%m/%d/%y %H:%M:%S')] $1"
}

# Start Broadway daemon and log output
log "Starting Broadway daemon..."
broadwayd :5 > >(while IFS= read -r line; do log "$line"; done) 2>&1 &

broadway_pid=$!

# Export environment variables
export GDK_BACKEND=broadway
export NICOTINE_GTK_VERSION=3
export BROADWAY_DISPLAY=:5
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$PUID/bus
export NO_AT_BRIDGE=1

# Set GTK theme if DARKMODE is enabled
if [[ $DARKMODE == "true" ]]; then
    export GTK_THEME=Adwaita:dark
fi

# Define config file paths
CONFIG_FILE="/home/nicotine/.config/nicotine/config"
CONFIG_DEFAULT="/home/nicotine/config-default"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log "Configuration file not found"
    log "Importing default configuration..." 
    cp "$CONFIG_DEFAULT" "$CONFIG_FILE" || { echo "Failed to import default configuration. Exiting..."; exit 1; }
fi

# Update config files with environment variables
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

# Launch Nicotine+ as the nicotine user
log "Starting Nicotine+..."
nicotine
