#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

"$SCRIPT_DIR/e2bctl.sh" stop || true

systemctl disable e2b-client-proxy e2b-api e2b-orchestrator e2b-local-infra >/dev/null 2>&1 || true

if [[ "${E2B_DESTROY_COMPOSE:-0}" == "1" ]]; then
  require_e2b_root
  (
    cd "$E2B_ROOT"
    docker compose -f packages/local-dev/docker-compose.yaml down
  )
fi

if [[ "${E2B_REMOVE_UNITS:-0}" == "1" ]]; then
  rm -f \
    /etc/systemd/system/e2b-local-infra.service \
    /etc/systemd/system/e2b-orchestrator.service \
    /etc/systemd/system/e2b-api.service \
    /etc/systemd/system/e2b-client-proxy.service
  systemctl daemon-reload
fi

cat <<'EOF'
Destroy complete.

By default this keeps Docker volumes, downloaded E2B artifacts, and /etc/e2b-linux-local.env.

Optional destructive modes:
  E2B_DESTROY_COMPOSE=1 sudo ./scripts/destroy.sh
  E2B_REMOVE_UNITS=1 sudo ./scripts/destroy.sh
EOF
