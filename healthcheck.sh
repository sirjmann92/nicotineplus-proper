#!/bin/bash

# Healthcheck script for Nicotine+ Docker container
# This script checks if both NGINX and the Broadway/Nicotine+ application are running
# Uses process checks instead of network checks to support VPN container networking
#
# Environment variables:
#   HEALTHCHECK_ENABLED - Set to "false" to disable healthcheck (default: true)


# Logging function to echo output with a timestamp
log() {
    echo "[$(date '+%m/%d/%y %H:%M:%S')] $1"
}

# Allow users to disable healthcheck via environment variable
if [ "${HEALTHCHECK_ENABLED}" = "false" ]; then
    log "Healthcheck disabled via HEALTHCHECK_ENABLED=false"
    exit 0
fi

# Check if NGINX process is running
if ! pgrep -x nginx > /dev/null 2>&1; then
    log "Healthcheck failed: NGINX process not running"
    exit 1
fi

# Check if Broadway process is running
# gtk4-broadwayd for GTK4, broadwayd for GTK3
if ! pgrep -x gtk4-broadwayd > /dev/null 2>&1 && ! pgrep -x broadwayd > /dev/null 2>&1; then
    log "Healthcheck failed: Broadway process not running"
    exit 1
fi

# Check if nicotine process is running
if ! pgrep -f "nicotine.*--isolated" > /dev/null 2>&1; then
    log "Healthcheck failed: Nicotine+ process not running"
    exit 1
fi

# All checks passed
log "Healthcheck passed: all processes running"
exit 0
