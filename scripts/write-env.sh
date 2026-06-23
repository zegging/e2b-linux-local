#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${E2B_ENV_FILE:-/etc/e2b-linux-local.env}"
E2B_USER_DEFAULT="${SUDO_USER:-${USER:-e2b}}"
E2B_HOME="$(getent passwd "$E2B_USER_DEFAULT" | cut -d: -f6)"
E2B_ROOT_DEFAULT="${E2B_HOME:-/opt/e2b}/src/e2b-infra"
HOST_IP="$(hostname -I | awk '{print $1}')"
NODE_DIR="$(sudo -u "$E2B_USER_DEFAULT" -H bash -lc 'dirname "$(command -v node 2>/dev/null || true)"' 2>/dev/null || true)"
EXTRA_PATH="${E2B_HOME:-/opt/e2b}/bin:${E2B_HOME:-/opt/e2b}/.local/bin"
if [[ -n "$NODE_DIR" ]]; then
  EXTRA_PATH="$EXTRA_PATH:$NODE_DIR"
fi

if [[ -f "$ENV_FILE" ]]; then
  echo "$ENV_FILE already exists; not overwriting."
  exit 0
fi

cat >"$ENV_FILE" <<EOF
# E2B single-host local deployment config.
E2B_ROOT=$E2B_ROOT_DEFAULT
E2B_USER=$E2B_USER_DEFAULT
E2B_GROUP=$E2B_USER_DEFAULT
E2B_NODE_ID=$(hostname)
E2B_PUBLIC_HOST=${HOST_IP:-127.0.0.1}
E2B_PATH=$EXTRA_PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Replace this with the seeded local dev API key from packages/local-dev.
E2B_API_KEY=<LOCAL_DEV_API_KEY>

ORCHESTRATOR_HEALTH=http://127.0.0.1:5008/health
API_HEALTH=http://127.0.0.1:3000/health
CLIENT_PROXY_HEALTH=http://127.0.0.1:3003/health
EOF

chmod 0644 "$ENV_FILE"
echo "Wrote $ENV_FILE"
