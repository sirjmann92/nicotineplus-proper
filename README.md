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
*   Support for custom WebUI port
*   Support for UID/GID assignment
*   Support for persistent configuration
*   Support for persistent logging
*   Darkmode
*   Favicon and tab label for neatness and easy identification in browsers
*   Dynamic, timestamped, contextual, logging for clean and consistent logs
*   Window control buttons are removed (thanks to the N+ developers!) for the Broadway implementation of Nicotine+
    *   This creates a more native browser-based experience

Included in image
-----------------

### Latest Version (tag: latest)

*   Official Ubuntu 24.04 Base Image
*   Nicotine+ 3.3.4
*   GTK 3.24.41
*   Python 3.12.3

### Installation

*   Create a directory named "config" on your local machine
*   Inside the "config" directory, create a directory named "data"
*   Map your local "config" directory to the "/config" directory in the container (see example)
*   Map your local "data" directory to the "/data" directory in the container (see example)

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

Docker Compose Example
----------------------

    ---
    version: '3.9'
    services: 
     nicotineplus-proper:
       image: 'sirjmann92/nicotineplus-proper:latest'
       container_name: nicotine
       network_mode: "container:YourVPNContainerNameHere" # Comment this line out if you're NOT using a VPN container
       ports: # Comment this line out if you ARE using a VPN container (line above)
         - '6565:6565' # Comment this line out if you ARE using a VPN container (lines above#)
    #  env_file: .env # Optionally use a .env file to store environment variables and login credentials
       environment: # All environment variables are optional, use as needed, defaults are listed
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
         - WEB_UI_PORT=6565 # for custom webUI port assignment. Should match 'port' env variable or VPN webUI port
       volumes:
         - /your/downloads/directory:/downloads
         - /your/share/directory:/shared
         - /your/local/directory/config:/config # Save your config persistently
         - /your/local/directory/config/data:/data # Store your logs, database, and history
       restart: unless-stopped

Docker Run Example
------------------

*   If you don't use a VPN container, don't use the --net command line below, instead use the "-p 6565:6565" line.
*   If you do use a separate VPN client container, you should configure the VPN to make port 6565, or your custom port, available.
*   The 'WEB_UI_PORT' is optional for custom ports, and should match the port (-p) environment variable or VPN
        
        docker run -d --name=nicotine
        //--net=container:YourVPNClientContainerName
        --restart=unless-stopped
        -v /your/media/directory:/downloads
        -v /your/share/directory:/shared
        -v /your/local/directory/config:/config
        -v /your/local/directory/config/data:/data
        -e LOGIN=YourSoulSeekUsername
        -e PASSW=YourSoulSeekPassword
        -e DARKMODE=True
        -e PUID=1000 # Optional: Default is 1000
        -e PGID=1000 # Optional: Default is 1000
        -e TRAY_ICON=False
        -e NOTIFY_FILE=False
        -e NOTIFY_FOLDER=False
        -e NOTIFY_TITLE=False
        -e NOTIFY_PM=False
        -e NOTIFY_CHATROOM=False
        -e NOTIFY_MENTION=False
        //-e WEB_UI_PORT=6565
        //-p 6565:6565
        sirjmann92/nicotineplus-proper:user

You can access your Nicotine+ WebUI with http://your.server.ip.here:6565 (e.g. http://192.168.1.555:6565)

Updating Nicotine+ (OPTIONAL)
-----------------------------

When a new version of Nicotine+ is released, you have two options of upgrading

1.  Wait for me to update the container and pull a new image
2.  If I haven't updated the container after a new version of Nictone+ has been released and you want the latest and greatest without waiting for me, you may manually update by following the directions below.

With a user that has Docker permissions (or sudo -i), SSH into your NAS/server or open your CLI terminal and run the following:

*   Make sure your nicotine container is RUNNING when you do this
*   Depending on which tag you're using, you may need to use "sudo"

        $docker exec -it nicotine bash
        $apt update
        $apt -y upgrade nicotine (if you only want to upgrade the Nicotine+ client)
        $apt -y upgrade (if you want to upgrade all packages in the container)
        $apt -y autoremove

    
Restart the container when finished. The `apt autoremove` command will check for any unnecessary packages and dependencies and remove any it finds, useful for controlling image size.
  
To list all packages contained in image (with version and description):

        $docker exec -i <container_id> dpkg -l

Building
--------

If you're interested in making modifications, or simply prefer to build your own image from the project files, you may download or clone the project and run the following from within the project directory:

        $docker build -t yourImageName .
