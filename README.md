Nicotine+ as a WebUI in a Docker container
==========================================

Nicotine+ is a graphical client for the Soulseek peer-to-peer network.
  
Nicotine+ aims to be a lightweight, pleasant, free and open source (FOSS) alternative to the official Soulseek client, while also providing a comprehensive set of features.
  
For more information, head to the official Nicotine+ website, at: [https://nicotine-plus.org](https://nicotine-plus.org)
  
This is a Nicotine+ Docker image, using port 6565 (by default) to access Nicotine+ in a browser using the Broadway backend of GTK as the display server. This makes the image extremely small, lightweight, and fast, because it has less complications and dependencies. This also means there is no authentication available to access the application (as there would be with noVNC). If you plan to use this remotely as part of your self-hosted setup, you'll need to use something like Authentik or Authelia to provide the authenticaion layer. Alternatively, you could use a self-hosted VPN server and access the application externally as if you're on the local network. These items are outside the scope of this project but I wanted to provide alternatives if you need to access the application while you're away from your local network.
  
Because the application runs natively in a browser when using the Broadway backend of GTK, there is no need for certain features or UI elements to be present (e.g. window control buttons). The Nicotene+ developers were kind enough to remove them for this project. Currently, the window control buttons (minimize, maximize/restore, close) are the only things that have been removed. This should prevent anyone from accidentally closing the application which would require restarting the container to restore it. An added bonus is the usability and accessibility perspectives of not having features available that are irrelevant in the context of a browser, allowing for a more streamlined browser-based experience.
  
This image is inspired by 33masterman33's clone of freddywullockx's Nicotine+ Docker image. Since the original release that was built on top of the aforementioned images, I've rebuilt the image from scratch, with expanded features and complexity. This is now a completely unique project, but loads of credit should still be given to freddywullockx and 33masterman33 for the inspiration and concept.

You can also find this project at: [https://hub.docker.com/r/sirjmann92/nicotineplus-proper](https://hub.docker.com/r/sirjmann92/nicotineplus-proper)

Features
-----------------
*   Custom WebUI port
*   UID/GID assignment
*   Time zone and locale (no locale on Alpine based images)
*   UMASK support
*   Configuration and log directory mapping
*   Custom plugin support
*   Darkmode
*   Favicon and tab label for neatness and easy identification in browsers
*   Dynamic, timestamped, contextual, logging for clean and consistent logs
*   NEW! Isolated Mode (test images only for now)
    *   This creates a more native browser-based experience by removing links and references to external applications and websites, among other things
    *   Big thanks to the N+ developers!

Included in image
-----------------

### Latest Version (tag: latest)

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ using GTK 3

### GTK 4 Version (tag: gtk4) - Will become "latest"

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ using GTK 4

### Alpine version (tag: alpine) - Will be deprecated

*   Official Alpine 3.21 Base Image
*   Latest Nicotine+ using GTK 3

### Latest Test Version (tag: test)

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ RC/dev branch using GTK 3
*   Isolated mode

### GTK 4 Version (tag: gtk4-test) - Will become "test"

*   Official Ubuntu 24.04 Base Image
*   Latest Nicotine+ RC/dev branch using GTK 4
*   Isolated Mode

### Alpine test version (tag: alpine-test) - Will be deprecated

*   Official Alpine 3.21 Base Image
*   Latest Nicotine+ RC/dev branch using GTK 4
*   Isolated mode

### Installation

*   Create a directory named "config" on your local machine
*   Inside the "config" directory, create a directory named "data"
*   Map your local "config" directory to the "/config" directory in the container (see example)
*   Map your local "data" directory to the "/data" directory in the container (see example)
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

#### NOTES

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

Docker Compose Example
----------------------

    ---
    version: '3.9'
    services: 
     nicotineplus-proper:
       image: 'sirjmann92/nicotineplus-proper:latest'
       container_name: nicotine
    #  network_mode: "container:YourVPNContainerNameHere" # Comment this line out if you're NOT using a VPN container
       ports: # Comment this line out if you ARE using a VPN container (line above)
         - '6565:6565' # Comment this line out if you ARE using a VPN container (lines above)
         - '2234:2234' # Comment this line out if you ARE using a VPN container (lines above)
    #  env_file: .env # Optionally use a .env file to store environment variables and login credentials
       environment: # All environment variables are optional, use as needed, defaults are listed (TZ, LANG, and UMASK have no default)
         - TZ=Your/Timezone
         - LANG=C.UTF-8
         - UMASK=022
         - DARKMODE=True
         - LOGIN=YourSoulSeekUsername
         - PASSW=YourSoulSeekPassword
         - PUID=1000
         - PGID=1000
         - UPNP=False 
         - AUTO_CONNECT=True
         - TRAY_ICON=False
         - NOTIFY_FILE=False
         - NOTIFY_FOLDER=False
         - NOTIFY_TITLE=False
         - NOTIFY_PM=False
         - NOTIFY_CHATROOM=False
         - NOTIFY_MENTION=False
      #  - WEB_UI_PORT=6565 # for custom webUI port assignment. Should match 'port' env variable or VPN webUI port
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
        -e LANG=C.UTF-8 \
        -e UMASK=022 \
        -e LOGIN=YourSoulSeekUsername \
        -e PASSW=YourSoulSeekPassword \
        -e DARKMODE=True \
        -e PUID=1000 # Optional: Default is 1000 \
        -e PGID=1000 # Optional: Default is 1000 \
        -e TRAY_ICON=False \
        -e NOTIFY_FILE=False \
        -e NOTIFY_FOLDER=False \
        -e NOTIFY_TITLE=False \
        -e NOTIFY_PM=False \
        -e NOTIFY_CHATROOM=False \
        -e NOTIFY_MENTION=False \
        //-e WEB_UI_PORT=6565 \
        //-p 6565:6565 \
        //-p 2234:2234 \
        sirjmann92/nicotineplus-proper:latest

You can access your Nicotine+ WebUI with http://your.server.ip.here:6565 (e.g. http://192.168.1.555:6565)

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
        
        
