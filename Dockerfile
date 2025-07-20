FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV PUID=1000 \
    PGID=1000 \
    UPNP=False \
    AUTO_CONNECT=True \
    TRAY_ICON=False \
    NOTIFY_FILE=False \
    NOTIFY_FOLDER=False \
    NOTIFY_TITLE=False \
    NOTIFY_PM=False \
    NOTIFY_CHATROOM=False \
    NOTIFY_MENTION=False \
    WEB_UI_PORT=6565 \
    GDK_BACKEND=broadway \
    BROADWAY_DISPLAY=:5 \
    NICOTINE_GTK_VERSION=3 \
    NO_AT_BRIDGE=1

# Expose port for the application
EXPOSE ${WEB_UI_PORT}

# Install dependencies and necessary packages
RUN apt-get update \
    && apt-get install -y gir1.2-gtk-3.0 \
    software-properties-common \
    gsettings-desktop-schemas \
    && apt-get install -y --no-install-recommends \
    gir1.2-adw-1 \
    gir1.2-gspell-1 \
    librsvg2-common \
    python3-gi \
    python3-gi-cairo \
    fonts-noto-cjk \
    gettext \
    dbus-x11 \
    nginx \
    tzdata \
    locales \
# Delete default ubuntu user claiming 1000:1000, create nicotine user and group
    && userdel -r ubuntu \
    && groupadd -g ${PGID} nicotine \
    && useradd -u ${PUID} -g ${PGID} -m -s /bin/bash nicotine \
# Create directories, symobolic links, and set permissions
    && mkdir -p /home/nicotine/.config/nicotine /home/nicotine/.local/share/nicotine/plugins \
    && ln -s /home/nicotine/.config/nicotine /config \
    && ln -s /home/nicotine/.local/share/nicotine /data \
    && ln -s /home/nicotine/.local/share/nicotine/plugins /data/plugins \
    && chown -R nicotine:nicotine /config /data /home/nicotine/.config /home/nicotine/.local /var/log \
# Add Nicotine+ repository, install Nicotine+, and cleanup
    && add-apt-repository ppa:nicotine-team/stable \
    && apt-get install -y nicotine \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get autoremove -y \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Import configuration files and launch scripts
COPY config-default /home/nicotine/config-default
COPY default /etc/nginx/sites-available/default
COPY favicon.ico /var/www/favicon.ico
COPY init.sh /usr/local/bin/init.sh
COPY launch.sh /usr/local/bin/launch.sh

# Run Nicotine+ startup script
CMD ["init.sh"]
