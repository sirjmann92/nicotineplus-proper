#!/bin/bash

# Healthcheck script for Nicotine+ Docker container
# This script checks if both NGINX and the Broadway/Nicotine+ application are running

# Get the configured WEB_UI_PORT (default to 6565 if not set)
PORT=${WEB_UI_PORT:-6565}

# Check if NGINX is responding
if ! curl -sf "http://localhost:${PORT}/" > /dev/null 2>&1; then
    echo "Healthcheck failed: NGINX not responding on port ${PORT}"
    exit 1
fi

# Check if Broadway is responding (NGINX proxies to localhost:8085)
# Note: Broadway port is hardcoded to 8085 in launch.sh (gtk4-broadwayd :5 runs on port 8085)
if ! curl -sf "http://localhost:8085/" > /dev/null 2>&1; then
    echo "Healthcheck failed: Broadway not responding on port 8085"
    exit 1
fi

# All checks passed
exit 0
