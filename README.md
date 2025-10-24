Nicotine+ as a WebUI in a Docker container
==========================================

Nicotine+ is a graphical client for the Soulseek peer-to-peer network.
  
Nicotine+ aims to be a lightweight, pleasant, free and open source (FOSS) alternative to the official Soulseek client, while also providing a comprehensive set of features.
  
For more information, head to the [official Nicotine+ website](https://nicotine-plus.org)
  
This is a Nicotine+ Docker image, using port 6565 (by default) to access Nicotine+ in a browser using the Broadway back end of GTK as the display server. This makes the image extremely small, lightweight, and fast, because it has less complications and dependencies. This also means there is no authentication available to access the application (as there would be with noVNC). If you plan to use this remotely as part of your self-hosted setup, you'll need to use something like Authentik or Authelia to provide the authenticaion layer. Alternatively, you could use a self-hosted VPN server and access the application externally as if you're on the local network. These items are outside the scope of this project but I wanted to provide alternatives if you need to access the application while you're away from your local network.

Because the application renders natively in a browser when using the Broadway back end of GTK, certain features and UI elements are not needed (e.g. window control buttons). The Nicotine+ developers were kind enough to create an isolated mode for this project. This creates a more native browser-based experience by removing links and references to external applications and websites, among other things. All of my images now run in isolated mode.

This image is inspired by 33masterman33's clone of freddywullockx's Nicotine+ Docker image. Since the original release that was built on top of the aforementioned images, I've rebuilt the image from scratch, with expanded features and complexity. This is now a completely unique project, but loads of credit should still be given to freddywullockx and 33masterman33 for the inspiration and concept.

You can also find this project [on the Docker Hub](https://hub.docker.com/r/sirjmann92/nicotineplus-proper)

Features
-----------------
*   NEW! Now available for both x86/amd64 and arm64 architectures
*   Port config override (for dynamic VPN forwarded ports)
*   Custom WebUI port
*   Authentication for Custom WebUI
*   UID/GID assignment
*   Time zone and locale (no locale on Alpine based images)
*   UMASK support
*   Configuration and log directory mapping
*   Custom plugin support
*   Darkmode
*   Favicon and tab label for neatness and easy identification in browsers
*   Dynamic, timestamped, contextual, logging for clean and consistent logs
*   Isolated Mode
    *   Tweaks for a contained environment (such as links to external applications, certain network settings, UI elements, etc.)
    *   [Details here](https://github.com/nicotine-plus/nicotine-plus/issues/3219#issue-2738992137)
    *   Big thanks to the N+ developers!
*   There are known issues with GTK4 and Broadway that can't be fixed by this image, use the GTK3 image if these bother you:
    *   Can't center dialog windows
    *   Grabbing scrollbars: if you move your mouse away while dragging the scrollbar, you lose control of it
    *   No clipboard management (copy/paste from out->in or in->out of the image won't work)
        * This is true for the GTK3 images too, no copy/paste, this is an upstream issue

Image variants:
---------------

#### Latest Version (tag: latest)

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ stable using GTK4

#### Latest Test Version (tag: test)

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ RC/dev using GTK4

#### GTK 3 Version (tag: gtk3)

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ using GTK 3

#### GTK 3 Test Version (tag: gtk3-test)

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ RC/dev branch using GTK 3

Installation
------------

*   Map a local "config" directory to the "/config" directory in the container (see example)
*   Map a local "data" directory to the "/data" directory in the container (see example)
    * Downloads directories will be created inside the /data directory by default.
    * For custom download directories, create a volume mapping (see example), then select the mapped volume in the Nicotine+ settings menu.
*   FOR CUSTOM PLUGINS: A "plugins" directory will be created automatically under the /data directory (/data/plugins) if it doesn't exist at container startup. Place your custom plugins here to use them in Nictotine+.
*   When setting a different locale, only LANG is required. LC_ALL and LANGUAGE will be updated by internal scripts. The Language setting in Nicotine+ will still need to be set manually by the user.

#### Docker Compose (recommended)

*   Create a filed named "docker-compose.yml" in the parent directory of the "config" directory you created above
*   Copy the Docker Compose Example code below and paste it into the "docker-compose.yml" file you created
*   Modify the code for your system/environment as needed
*   Run "docker-compose up -d" in your CLI from the directory where your compose yaml file is located

#### Docker Run

*   Copy the Docker Run snippet below
*   Paste the snippet into a text editor or somewhere you can modify it
*   Make any necessary changes to the script, then save it for future use
*   Copy and paste the script into your CLI from the parent directory of the "config" directory you created above

NOTES
-----

*   On first run, if there is no previous config found, a default config will be imported before writing environment variables.
*   IMPORTANT: Make sure the PUID and PGID you use match your host's UID and GID, otherwise you may end up with permission issues
    *   If you don't know your UID/GID:
        *   For Linux, at a terminal prompt enter "id" and press enter
        *   For Docker on Windows, use "id -u" and "id -g" for the user and group you should use
*   If you don't use a VPN container, don't use the --net or network_mode commands, instead directly map ports 6565 and 2234
*   If you do use a separate VPN client container, you need to make your mapped ports available to the VPN (defaults are 6565 and 2234)
*   The default listen port is 2234, if you change it in the N+ settings, then you also need to change it in your script and/or VPN
*   The listen port should be open in your router (default is 2234), unless you use a VPN
*   If you use a VPN, the listen port should be forwarded in your VPN host's settings (default is 2234)
*   The 'WEB_UI_PORT' is optional for custom Web UI ports, if using a VPN make sure this port is available
*   The 'FORWARD_PORT' environment variable will update the listening port in the config file, before starting the container
    *   This variable may be used with dynamic ports from VPN providers, along with a custom script/setup
    *   Supporting dynamic port setups is outside the scope of this project, but [here is one example and solution](https://github.com/sirjmann92/nicotineplus-proper/issues/19#issuecomment-2931876766)

Docker Compose Example
----------------------

    ---
    services: 
     nicotineplus-proper:
       image: 'sirjmann92/nicotineplus-proper:latest'
       container_name: nicotine
    #  network_mode: "container:YourVPNContainerNameHere" # Comment this line out if you're NOT using a VPN container
       ports: # Comment this line out if you ARE using a VPN container (line above)
         - '6565:6565' # Comment this line out if you ARE using a VPN container (lines above)
         - '2234:2234' # Comment this line out if you ARE using a VPN container (lines above)
    #  env_file: .env # Optionally use a .env file to store environment variables and login credentials
       environment: # All environment variables are optional, defaults are listed (TZ, LANG, UMASK, and FORWARD_PORT have no default)
         - TZ=Your/Timezone
         - LOGIN=YourSoulSeekUsername
         - PASSW=YourSoulSeekPassword
      #   - PUID=1000
      #   - PGID=1000
      #   - DARKMODE=True
      #   - LANG=C.UTF-8
      #   - UMASK=022
      #   - UPNP=False 
      #   - AUTO_CONNECT=True
      #   - TRAY_ICON=False
      #   - NOTIFY_FILE=False
      #   - NOTIFY_FOLDER=False
      #   - NOTIFY_TITLE=False
      #   - NOTIFY_PM=False
      #   - NOTIFY_CHATROOM=False
      #   - NOTIFY_MENTION=False
      #   - FORWARD_PORT=12345 # Useful for dynamic port forwarding
      #   - WEB_UI_PORT=6565 # for custom webUI port assignment. Should match 'port' env variable or VPN webUI port
      #   - WEB_UI_USER=YourWebUIUsername # for custom webUI basic auth username
      #   - WEB_UI_PASSWORD=YourWebUIPassword # for custom webUI basic auth password
       volumes:
         - /your/downloads/directory:/downloads
         - /your/share/directory:/shared
         - /your/local/directory/config:/config # Save your config persistently
         - /your/local/directory/config/data:/data # Store your logs, database, and history
       restart: unless-stopped

Docker Run Example
------------------
        
        docker run -d --name=nicotine \
        //--net=container:YourVPNClientContainerName \
        --restart=unless-stopped \
        -v /your/media/directory:/downloads \
        -v /your/share/directory:/shared \
        -v /your/local/directory/config:/config \
        -v /your/local/directory/config/data:/data \
        -e TZ=Your/Timezone \
        -e LOGIN=YourSoulSeekUsername \
        -e PASSW=YourSoulSeekPassword \
        -e PUID=1000 \
        -e PGID=1000 \
        //-e DARKMODE=True \
        //-e LANG=C.UTF-8 \
        //-e UMASK=022 \
        //-e FORWARD_PORT=12345 \
        //-e WEB_UI_PORT=6565 \
        //-e WEB_UI_USER=YourWebUIUsername \
        //-e WEB_UI_PASSWORD=YourWebUIPassword \
        -p 6565:6565 \
        -p 2234:2234 \
        sirjmann92/nicotineplus-proper:latest

You can access your Nicotine+ WebUI with http://your.server.ip.here:6565 (e.g. http://192.168.1.555:6565)

Important Note About Reverse Proxies and WebSockets
---------------------------------------------------

**The container is pre-configured to handle WebSocket connections properly when accessed directly.** However, if you're using a reverse proxy (Nginx Proxy Manager, Traefik, Caddy, etc.) in front of this container, **you must configure your reverse proxy to handle WebSocket connections**, otherwise the Broadway interface will disconnect after a few minutes.

This is a limitation of how WebSockets work through multiple proxy layers - each proxy in the chain must be configured to maintain the WebSocket connection. The container's internal nginx is already configured correctly, but your external reverse proxy needs WebSocket support enabled as well.

#### Why This Is Necessary

Broadway (the GTK display backend) uses WebSockets to maintain a live connection between your browser and the application. When you access the container directly, everything works seamlessly. However, when you add a reverse proxy:

- **Without WebSocket config**: The reverse proxy treats the connection as a regular HTTP request and may time out idle connections (typically after 3 minutes)
- **With WebSocket config**: The reverse proxy properly upgrades the connection and maintains it indefinitely

#### Reverse Proxy Configuration Examples

**Nginx Proxy Manager / Nginx** - Add to "Advanced" tab or custom location:
```nginx
location /socket {
    proxy_pass http://container-ip:6565/socket;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_read_timeout 86400;
    proxy_send_timeout 86400;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

**Traefik** - Add these labels to your docker-compose:
```yaml
labels:
  - "traefik.http.routers.nicotine.middlewares=nicotine-headers"
  - "traefik.http.middlewares.nicotine-headers.headers.customrequestheaders.Connection=upgrade"
  - "traefik.http.middlewares.nicotine-headers.headers.customrequestheaders.Upgrade=websocket"
```

**Caddy** - Add to your Caddyfile:
```
your.domain.com {
    reverse_proxy /socket* container-ip:6565 {
        flush_interval -1
    }
    reverse_proxy container-ip:6565
}
```

If you're using an authentication proxy like Authentik or Authelia, the WebSocket configuration must be applied to the reverse proxy that sits in front of the authentication layer, not within the authentication proxy itself.

Updating Nicotine+ (OPTIONAL)
-----------------------------

When a new version of Nicotine+ is released, you have two options of upgrading

1.  Wait for me to update the container and pull a new image
2.  If I haven't updated the container after a new version of Nictone+ has been released and you want the latest and greatest without waiting for me, you may manually update by following the directions below.

Make sure your nicotine container is RUNNING when you do this
*   With a user that has Docker permissions (or sudo), SSH into your NAS/server or open your CLI terminal
*   To connect to your container's shell (command line), copy and paste this into your terminal

        sudo docker exec -it nicotine bash

*   If you want to update all packages inside the container, copy and paste this into your container's shell:

        apt update &&
        apt -y upgrade &&
        apt -y autoremove

*   If you only want to update Nicotine+ inside the container, copy and paste this instead:
        
        apt update &&
        apt -y upgrade nicotine &&
        apt -y autoremove
    
Restart the container when finished. The `apt autoremove` command will check for any unnecessary packages and dependencies and remove any it finds, useful for controlling image size.
  
To list all packages contained in image (with version and description):

        docker exec -i <container_id> dpkg -l
        
Building
--------

If you're interested in making modifications, or simply prefer to build your own image from the project files, you may download or clone the project and run the following from within the project directory:

        docker build -t yourImageName .
        
        
