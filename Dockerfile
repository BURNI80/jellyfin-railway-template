# Jellyfin + FileBrowser template for Railway
# Base: official Jellyfin 10.11.11 image (Debian trixie-slim, runs as root)
FROM jellyfin/jellyfin:10.11.11

# Install nginx (single public entry point / reverse proxy)
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests nginx-light \
    && rm -rf /var/lib/apt/lists/*

# Install FileBrowser (web file uploader), pinned to a stable release
ARG FILEBROWSER_VERSION=v2.63.23
RUN curl -fsSL "https://github.com/filebrowser/filebrowser/releases/download/${FILEBROWSER_VERSION}/linux-amd64-filebrowser.tar.gz" \
        -o /tmp/filebrowser.tar.gz \
    && tar -xzf /tmp/filebrowser.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/filebrowser \
    && rm /tmp/filebrowser.tar.gz

# Runtime assets
COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8095

ENTRYPOINT ["/docker-entrypoint.sh"]
