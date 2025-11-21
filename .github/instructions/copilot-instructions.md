# GitHub Copilot Instructions for nicotineplus-proper

## Repository Overview

This repository contains a Docker-based implementation of Nicotine+ (a Soulseek peer-to-peer network client) that runs as a WebUI using the GTK Broadway backend. The project provides a lightweight, browser-accessible interface for Nicotine+ without requiring VNC or traditional desktop environments.

## Project Architecture

### Core Technologies
- **Docker**: Ubuntu 24.04 base image
- **GTK Broadway**: Display server for rendering GTK applications in browsers via WebSockets
- **Nicotine+**: The Soulseek client application (GTK4 and GTK3 variants)
- **NGINX**: Web server for serving the Broadway interface
- **Bash**: Init and launch scripts for container initialization

### Key Components
1. **Dockerfile**: Defines the container image, installs dependencies, creates user/group, sets up directories
2. **init.sh**: Container initialization script (runs as root, then switches to nicotine user)
3. **launch.sh**: Application launch script (runs as nicotine user)
4. **config-default**: Default Nicotine+ configuration template
5. **default**: NGINX configuration for Broadway WebSocket support
6. **favicon.ico**: Browser tab icon

## File Structure

```
/
├── Dockerfile           # Container build definition
├── init.sh             # Container initialization (root)
├── launch.sh           # Application launcher (user)
├── config-default      # Default Nicotine+ config
├── default             # NGINX config
├── favicon.ico         # Browser favicon
├── README.md           # Documentation
└── .github/
    └── instructions/   # Copilot instructions
```

## Coding Standards

### Bash Scripts
- Use `#!/bin/bash` shebang
- Include logging function: `log() { echo "[$(date '+%m/%d/%y %H:%M:%S')] $1"; }`
- Always log significant actions and state changes
- Use `set -e` cautiously; handle errors explicitly where appropriate
- Quote variables to prevent word splitting: `"$VARIABLE"`
- Use `${VARIABLE:-default}` for variables with defaults
- Check file/directory existence before operations
- Maintain consistent indentation (4 spaces)

### Dockerfile
- Use multi-stage builds if adding complexity
- Minimize layers by combining RUN commands
- Clean up apt cache: `rm -rf /var/lib/apt/lists/*`
- Use `--no-install-recommends` for apt to reduce image size
- Set `DEBIAN_FRONTEND=noninteractive` for non-interactive installs
- Document all exposed ports and volumes
- Use ARG for build-time variables, ENV for runtime

### NGINX Configuration
- Maintain WebSocket support for Broadway connections
- Use appropriate timeout values (86400s for WebSocket connections)
- Support optional HTTP Basic Auth via environment variables
- Keep configuration minimal and focused

## Environment Variables

The container supports extensive customization via environment variables:

### Required/Common
- `TZ`: Timezone (e.g., `America/New_York`)
- `LOGIN`: Soulseek username
- `PASSW`: Soulseek password
- `PUID`/`PGID`: User/Group ID for file permissions (default: 1000)

### Optional Features
- `DARKMODE`: Enable/disable dark theme (default: True)
- `WEB_UI_PORT`: Custom WebUI port (default: 6565)
- `WEB_UI_USER`/`WEB_UI_PASSWORD`: HTTP Basic Auth credentials
- `FORWARD_PORT`: Dynamic port forwarding support
- `LANG`: Locale setting
- `UMASK`: File creation mask
- Various notification toggles (`NOTIFY_*`)
- Auto-connect, tray icon, UPnP settings

## Development Guidelines

### Making Changes

1. **Preserve Existing Functionality**: This project serves active users. Don't break working features.

2. **Minimize Image Size**: 
   - Clean up after package installations
   - Use `--no-install-recommends`
   - Remove temporary files and caches

3. **Maintain Permissions**:
   - The container runs as the `nicotine` user (PUID:PGID)
   - Ensure all files in `/config` and `/data` are owned correctly
   - Broadway socket requires specific permissions (mode 755 on cache directory)

4. **Logging**:
   - Use the `log()` function for all user-facing messages
   - Include timestamps for debugging
   - Filter out harmless GTK warnings in launch.sh

5. **Configuration Management**:
   - Never overwrite user configurations without checks
   - Import defaults only when no config exists
   - Use `sed` to update specific config values from environment variables
   - Preserve user customizations

6. **Security**:
   - Don't log sensitive information (passwords, tokens)
   - Validate environment variable inputs where appropriate
   - Use proper file permissions (avoid world-writable files)

### Testing Approach

Since this is a Docker project, testing involves:

1. **Build Testing**: Ensure Dockerfile builds successfully
   ```bash
   docker build -t test-image .
   ```

2. **Runtime Testing**: Verify container starts and functions
   ```bash
   docker run -d --name test-container -p 6565:6565 test-image
   # Access http://localhost:6565 and verify Broadway interface loads
   ```

3. **Environment Variable Testing**: Test common customizations
   - Different PUID/PGID values
   - Custom WEB_UI_PORT
   - HTTP Basic Auth
   - Dark mode toggle

4. **Log Verification**: Check container logs for errors
   ```bash
   docker logs test-container
   ```

5. **Permission Testing**: Verify file ownership in volumes
   ```bash
   docker exec test-container ls -la /config /data
   ```

### Common Pitfalls to Avoid

1. **Don't break Broadway WebSocket support**: The NGINX config must maintain WebSocket upgrade headers
2. **Don't change default port assumptions**: Many users rely on port 6565 and 2234
3. **Don't remove the isolated mode flag**: Nicotine+ runs with `--isolated` for this use case
4. **Don't modify user's existing config values**: Only update from environment variables
5. **Don't assume UID 1000 is always available**: The Dockerfile deletes the ubuntu user claiming 1000:1000

### File Modification Guidelines

- **Dockerfile**: Changes here require image rebuild and may affect all users
- **init.sh**: Runs as root, handles system-level setup (user creation, NGINX, permissions)
- **launch.sh**: Runs as nicotine user, handles app-level setup (config, Broadway, Nicotine+ startup)
- **config-default**: Template only, never modified at runtime
- **default (NGINX)**: Contains placeholder `__PORT__` replaced by init.sh

## Special Considerations

### GTK Broadway Limitations
- No clipboard support (copy/paste in/out of container)
- GTK4 has dialog centering issues and scrollbar grabbing quirks
- WebSocket connection required (timeouts if proxy not configured)

### Volume Mappings
- `/config`: Persistent Nicotine+ configuration
- `/data`: Logs, database, downloads, plugins
- Custom download directories can be mounted separately

### Network Modes
- **Direct**: Map ports 6565 and 2234 directly
- **VPN Container**: Use `network_mode: "container:vpn_container"`

## When to Be Cautious

1. **Changing the User Setup**: The `nicotine` user setup is delicate (deleting ubuntu user, claiming UID 1000)
2. **Modifying Config File Parsing**: sed commands are fragile; test thoroughly
3. **Altering NGINX Configuration**: Must maintain WebSocket support
4. **Changing the Broadway Setup**: Socket permissions and timing are critical
5. **Locale/Timezone Handling**: Different distros handle these differently

## Preferred Solutions

- Use existing Debian/Ubuntu tools rather than adding new dependencies
- Preserve backward compatibility with existing user configurations
- Keep scripts readable and maintainable over clever one-liners
- Document environment variables in both README and code comments
- Use well-tested NGINX patterns for reverse proxy configurations

## Resources

- Nicotine+ Official: https://nicotine-plus.org
- GTK Broadway Documentation: https://docs.gtk.org/gtk4/broadway.html
- Project Docker Hub: https://hub.docker.com/r/sirjmann92/nicotineplus-proper
- Base Image: Ubuntu 24.04 official image
