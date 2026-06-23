#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

"$SCRIPT_DIR/write-env.sh"

# shellcheck disable=SC1090
source /etc/e2b-linux-local.env

install -d /opt/e2b-linux-local/scripts
install -m 0755 "$SCRIPT_DIR"/*.sh /opt/e2b-linux-local/scripts/

for unit in "$ROOT_DIR/systemd/"*.service; do
  target="/etc/systemd/system/$(basename "$unit")"
  sed \
    -e "s|{{E2B_ROOT}}|$E2B_ROOT|g" \
    -e "s|{{E2B_USER}}|$E2B_USER|g" \
    -e "s|{{E2B_GROUP}}|$E2B_GROUP|g" \
    -e "s|{{E2B_PATH}}|$E2B_PATH|g" \
    "$unit" >"$target"
  chmod 0644 "$target"
done

systemctl daemon-reload

echo "Installed systemd units:"
echo "  e2b-local-infra.service"
echo "  e2b-orchestrator.service"
echo "  e2b-api.service"
echo "  e2b-client-proxy.service"
echo
echo "Start with:"
echo "  sudo /opt/e2b-linux-local/scripts/e2bctl.sh start"
