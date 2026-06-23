#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

echo "== e2b-linux-local plan =="
print_env_summary
echo

"$SCRIPT_DIR/preflight.sh"

cat <<EOF

Planned local resources:
  systemd:
    - e2b-local-infra
    - e2b-orchestrator
    - e2b-api
    - e2b-client-proxy

  host runtime:
    - nbd module with nbds_max=64
    - vm.nr_hugepages=2048
    - net.ipv4.ip_forward=1
    - vm.unprivileged_userfaultfd=1

  upstream E2B local infra:
    - docker compose file: $E2B_ROOT/packages/local-dev/docker-compose.yaml

Next:
  make apply
EOF
