#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_e2b_root

wait_for_health "orchestrator" "$ORCHESTRATOR_HEALTH" 5
wait_for_health "api" "$API_HEALTH" 5
wait_for_health "client-proxy" "$CLIENT_PROXY_HEALTH" 5

cd "$E2B_ROOT"
make -C packages/shared/scripts local-build-base-template
