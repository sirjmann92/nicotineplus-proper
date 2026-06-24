FROM ubuntu:26.04
ARG DEBIAN_FRONTEND=noninteractive
ARG BROTWAY_RELEASE=v3.1.2
ARG GTK_VERSION=4.22.4

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
    NICOTINE_GTK_VERSION=4 \
    NO_AT_BRIDGE=1 \
    NICOTINE_DATA_HOME=/home/nicotine/.local/share/nicotine \
    LD_LIBRARY_PATH=/usr/lib/gtk4-brotway

# Expose port for the application
EXPOSE ${WEB_UI_PORT}

# Install runtime dependencies and necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gir1.2-gtk-4.0 \
    gir1.2-adw-1 \
    gir1.2-gspell-1 \
    librsvg2-common \
    python3-gi \
    python3-gi-cairo \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    gettext \
    dbus-x11 \
    nginx-light \
    tzdata \
    locales \
    curl \
    wget \
    apache2-utils \
# Delete default ubuntu user claiming 1000:1000, create nicotine user and group
    && userdel -r ubuntu \
    && groupadd -g ${PGID} nicotine \
    && useradd -u ${PUID} -g ${PGID} -m -s /bin/bash nicotine \
# Create directories, symobolic links, and set permissions
    && mkdir -p /home/nicotine/.config/nicotine /home/nicotine/.local/share/nicotine/plugins \
                /home/nicotine/.local/share/nicotine/downloads \
                /home/nicotine/.local/share/nicotine/incomplete \
                /home/nicotine/.local/share/nicotine/received \
    && ln -s /home/nicotine/.config/nicotine /config \
    && ln -s /home/nicotine/.local/share/nicotine /data \
    && ln -s /home/nicotine/.local/share/nicotine/plugins /data/plugins \
    && chown -R nicotine:nicotine /config /data /home/nicotine/.config /home/nicotine/.local /var/log \
# Install Nicotine+ and cleanup
#    && add-apt-repository ppa:nicotine-team/stable \
    && apt-get install -y nicotine \
# Install GTK Broadway fork (Brotway)
    && apt-get update \
    && set -eux \
    && arch="$(dpkg --print-architecture)" \
    && deb="gtk4-brotway_${GTK_VERSION}-${BROTWAY_RELEASE#v}_${arch}.deb" \
    && url="https://github.com/droserasprout/gtk-brotway/releases/download/${BROTWAY_RELEASE}/${deb}" \
    && wget -O "/tmp/${deb}" "${url}" \
    && apt-get install -y --no-install-recommends "/tmp/${deb}" \
# Cleanup
    && apt-get purge -y software-properties-common \
    && apt-get autoremove -y \
    && apt-get autoclean \
# Force-remove duplicate stock GTK4 + its GL/Mesa/LLVM dependency chain.
# Brotway provides its own copy of these libs at /usr/lib/gtk4-brotway
# (loaded via LD_LIBRARY_PATH). The stock copies are pulled in transitively
# by gir1.2-gtk-4.0/nicotine and are never actually used at runtime.
# Using dpkg directly (not apt) avoids cascading removal of gir1.2-gtk-4.0,
# libadwaita-1-0, and gtk4-brotway, which depend on these on paper but
# don't need them present on disk.
    && dpkg --purge --force-depends \
    libgtk-4-1 \
    libgtk-4-bin \
    libgstreamer-gl1.0-0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libgbm1 \
    libgl1-mesa-dri \
    libegl-mesa0 \
    libglx-mesa0 \
    mesa-libgallium \
    libllvm21 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb "/tmp/${deb}"

# Import configuration files and launch scripts
COPY config-default /home/nicotine/config-default
COPY default /etc/nginx/sites-available/default
COPY init.sh /usr/local/bin/init.sh
COPY launch.sh /usr/local/bin/launch.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

# Make healthcheck script executable
RUN chmod +x /usr/local/bin/healthcheck.sh

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["/usr/local/bin/healthcheck.sh"]

# Run Nicotine+ startup script
CMD ["init.sh"]
