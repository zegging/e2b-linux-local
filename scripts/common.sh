#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${E2B_ENV_FILE:-/etc/e2b-linux-local.env}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

E2B_ROOT="${E2B_ROOT:-$HOME/src/e2b-infra}"
E2B_USER="${E2B_USER:-$(id -un)}"
E2B_GROUP="${E2B_GROUP:-$(id -gn)}"
E2B_NODE_ID="${E2B_NODE_ID:-$(hostname)}"
E2B_PUBLIC_HOST="${E2B_PUBLIC_HOST:-127.0.0.1}"
E2B_API_KEY="${E2B_API_KEY:-<LOCAL_DEV_API_KEY>}"
E2B_PATH="${E2B_PATH:-$HOME/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}"

ORCHESTRATOR_HEALTH="${ORCHESTRATOR_HEALTH:-http://127.0.0.1:5008/health}"
API_HEALTH="${API_HEALTH:-http://127.0.0.1:3000/health}"
CLIENT_PROXY_HEALTH="${CLIENT_PROXY_HEALTH:-http://127.0.0.1:3003/health}"

require_e2b_root() {
  if [[ ! -d "$E2B_ROOT" ]]; then
    echo "E2B_ROOT does not exist: $E2B_ROOT" >&2
    exit 1
  fi
}

as_e2b_user() {
  if [[ "$(id -un)" == "$E2B_USER" ]]; then
    bash -lc "$*"
  else
    sudo -u "$E2B_USER" -H bash -lc "$*"
  fi
}

wait_for_health() {
  local name="$1"
  local url="$2"
  local attempts="${3:-60}"

  for _ in $(seq 1 "$attempts"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "$name is healthy"
      return 0
    fi
    sleep 2
  done

  echo "$name did not become healthy: $url" >&2
  return 1
}

print_env_summary() {
  cat <<EOF
E2B_ROOT=$E2B_ROOT
E2B_USER=$E2B_USER
E2B_GROUP=$E2B_GROUP
E2B_NODE_ID=$E2B_NODE_ID
E2B_PUBLIC_HOST=$E2B_PUBLIC_HOST
E2B_PATH=$E2B_PATH
ENV_FILE=$ENV_FILE
EOF
}
