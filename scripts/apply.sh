#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_e2b_root

"$SCRIPT_DIR/prepare-host.sh"
"$SCRIPT_DIR/install-systemd.sh"

systemctl enable e2b-local-infra e2b-orchestrator e2b-api e2b-client-proxy

"$SCRIPT_DIR/e2bctl.sh" start

cat <<EOF

Apply complete.

API:          http://$E2B_PUBLIC_HOST:3000
Sandbox URL:  http://$E2B_PUBLIC_HOST:3002
Health:       http://$E2B_PUBLIC_HOST:3003/health

Build base template once if needed:
  ./scripts/build-base-template.sh
EOF
