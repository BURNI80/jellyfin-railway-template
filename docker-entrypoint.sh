#!/bin/sh
# Jellyfin + FileBrowser + nginx entry point.
# Runs inside the official jellyfin/jellyfin image (as root).
set -eu

# Timezone (used by Jellyfin and the OS)
: "${TZ:=Etc/UTC}"
export TZ

# Public port Railway routes to. Must stay 8095 (see nginx.conf).
: "${PORT:=8095}"

CONFIG_DIR="/config"
MEDIA_DIR="${CONFIG_DIR}/media"
FILEBROWSER_DB="${CONFIG_DIR}/filebrowser.db"
FILEBROWSER_CONFIG="${CONFIG_DIR}/filebrowser.json"
FILEBROWSER_ROOT="${MEDIA_DIR}"
FILEBROWSER_ADDR="127.0.0.1"
FILEBROWSER_PORT="8080"

# --- 1. Persistent media folders -------------------------------------------
mkdir -p "${MEDIA_DIR}/Movies" "${MEDIA_DIR}/TV Shows" "${MEDIA_DIR}/Music"

# --- 2. FileBrowser admin password -----------------------------------------
# FILEBROWSER_PASSWORD wins if set. Otherwise reuse the stored password (so it
# survives redeploys), or generate one on the very first boot.
if [ -z "${FILEBROWSER_PASSWORD:-}" ]; then
    if [ -f "${CONFIG_DIR}/.filebrowser-password" ]; then
        FILEBROWSER_PASSWORD="$(cat "${CONFIG_DIR}/.filebrowser-password")"
        echo "[entrypoint] Reusing stored FileBrowser password from ${CONFIG_DIR}/.filebrowser-password"
    else
        FILEBROWSER_PASSWORD="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 16)"
        echo "${FILEBROWSER_PASSWORD}" > "${CONFIG_DIR}/.filebrowser-password"
        chmod 600 "${CONFIG_DIR}/.filebrowser-password"
        echo "[entrypoint] Generated a FileBrowser password and stored it at ${CONFIG_DIR}/.filebrowser-password"
    fi
fi

# --- 3. Initialize / sync FileBrowser admin user (idempotent) --------------
if [ -f "${FILEBROWSER_DB}" ]; then
    # DB already exists: keep the admin password in sync with FILEBROWSER_PASSWORD
    if ! filebrowser users update admin --password "${FILEBROWSER_PASSWORD}" \
        --database "${FILEBROWSER_DB}" \
        --config "${FILEBROWSER_CONFIG}" 2>/dev/null; then
        filebrowser users add admin "${FILEBROWSER_PASSWORD}" \
            --database "${FILEBROWSER_DB}" \
            --config "${FILEBROWSER_CONFIG}" \
            --perm.admin
    fi
    echo "[entrypoint] FileBrowser admin user 'admin' is up to date."
else
    echo "[entrypoint] Initializing FileBrowser database..."
    filebrowser config init \
        --database "${FILEBROWSER_DB}" \
        --config "${FILEBROWSER_CONFIG}" \
        --address "${FILEBROWSER_ADDR}" \
        --port "${FILEBROWSER_PORT}" \
        --root "${FILEBROWSER_ROOT}" \
        --baseURL "/files" \
        --minimumPasswordLength 1
    filebrowser users add admin "${FILEBROWSER_PASSWORD}" \
        --database "${FILEBROWSER_DB}" \
        --config "${FILEBROWSER_CONFIG}" \
        --perm.admin
    echo "[entrypoint] FileBrowser admin user 'admin' created."
fi

# --- 4. Start sidecar processes ----------------------------------------------
# Keep Jellyfin's LD_PRELOAD (jemalloc) for Jellyfin only; avoid preloading it
# into nginx and the Go FileBrowser binary.
JELLYFIN_PRELOAD="${LD_PRELOAD:-}"
unset LD_PRELOAD

echo "[entrypoint] Starting FileBrowser on ${FILEBROWSER_ADDR}:${FILEBROWSER_PORT} (base URL /files)..."
filebrowser \
    --database "${FILEBROWSER_DB}" \
    --config "${FILEBROWSER_CONFIG}" \
    --address "${FILEBROWSER_ADDR}" \
    --port "${FILEBROWSER_PORT}" \
    --root "${FILEBROWSER_ROOT}" \
    --baseURL "/files" &
FILEBROWSER_PID=$!

echo "[entrypoint] Starting nginx on port ${PORT}..."
nginx -g 'daemon off;' &
NGINX_PID=$!

# Give the sidecars a moment, fail fast if they die.
sleep 2
if ! kill -0 "${FILEBROWSER_PID}" 2>/dev/null; then
    echo "[entrypoint] FileBrowser exited during startup." >&2
    exit 1
fi
if ! kill -0 "${NGINX_PID}" 2>/dev/null; then
    echo "[entrypoint] nginx exited during startup." >&2
    exit 1
fi

# --- 5. Start Jellyfin (replaces the shell so it owns PID 1) ----------------
if [ -n "${JELLYFIN_PRELOAD}" ]; then
    export LD_PRELOAD="${JELLYFIN_PRELOAD}"
fi
echo "[entrypoint] Starting Jellyfin..."
exec /jellyfin/jellyfin
