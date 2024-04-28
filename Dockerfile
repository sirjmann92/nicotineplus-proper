FROM ubuntu:24.04

# Set environment variables
ENV LOGIN= \
    PASSW= \
    DARKMODE= \
    PUID=1000 \
    PGID=1000 \
    UPNP=False \
    AUTO_CONNECT=True \
    TRAY_ICON=False \
    NOTIFY_FILE=False \
    NOTIFY_FOLDER=False \
    NOTIFY_TITLE=False \
    NOTIFY_PM=False \
    NOTIFY_CHATROOM=False \
    NOTIFY_MENTION=False

# Expose port for the application
EXPOSE 6565

# Install dependencies and necessary packages
RUN apt-get update \
    && apt-get install -y gir1.2-gtk-3.0 \
    && apt-get install -y --no-install-recommends \
    software-properties-common \
    nginx \
    dbus-x11 \
    gir1.2-adw-1 \
    gir1.2-gspell-1 \
# Clean things up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \ 
# Delete default ubuntu user claiming 1000:1000, create nicotine user and group
    && userdel -r ubuntu \
    && groupadd -g ${PGID} nicotine \
    && useradd -u ${PUID} -g ${PGID} -m -s /bin/bash nicotine \
# Create directories, symobolic links, and set permissions
    && mkdir -p /home/nicotine/.config/nicotine /home/nicotine/.local/share/nicotine /home/nicotine/.config/dconf \
    && ln -s /home/nicotine/.config/nicotine /config \
    && ln -s /home/nicotine/.local/share/nicotine /data \
    && chown -R nicotine:nicotine /config /data /home/nicotine/.config /home/nicotine/.local /var/log \
# Add Nicotine+ repository, install Nicotine+, and final cleanup
    && add-apt-repository ppa:nicotine-team/unstable \
    && apt-get upgrade -y \
    && apt-get install -y nicotine \
    && apt-get autoclean \
    && apt-get autoremove

# Import default Nicotine+ config, nginx config, favicon, and initialization script
COPY config-default /home/nicotine/config-default
COPY default /etc/nginx/sites-available/default
COPY favicon.ico /var/www/favicon.ico
COPY init.sh /usr/local/bin/init.sh
COPY launch.sh /usr/local/bin/launch.sh

# Run Nicotine+ startup script
CMD ["init.sh"]
