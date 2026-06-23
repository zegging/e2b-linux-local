#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<'EOF'
Usage:
  e2bctl.sh start
  e2bctl.sh stop
  e2bctl.sh restart
  e2bctl.sh status
  e2bctl.sh logs [local-infra|orchestrator|api|client-proxy]
EOF
}

service_name() {
  case "$1" in
    local-infra) echo "e2b-local-infra" ;;
    orchestrator) echo "e2b-orchestrator" ;;
    api) echo "e2b-api" ;;
    client-proxy) echo "e2b-client-proxy" ;;
    *) echo "$1" ;;
  esac
}

start_all() {
  sudo systemctl start e2b-local-infra
  sudo systemctl start e2b-orchestrator
  wait_for_health "orchestrator" "$ORCHESTRATOR_HEALTH" 90
  sudo systemctl start e2b-api
  wait_for_health "api" "$API_HEALTH" 90
  sudo systemctl start e2b-client-proxy
  wait_for_health "client-proxy" "$CLIENT_PROXY_HEALTH" 90
}

stop_all() {
  sudo systemctl stop e2b-client-proxy || true
  sudo systemctl stop e2b-api || true
  sudo systemctl stop e2b-orchestrator || true
}

case "${1:-}" in
  start)
    start_all
    ;;
  stop)
    stop_all
    ;;
  restart)
    stop_all
    start_all
    ;;
  status)
    systemctl --no-pager --full status e2b-local-infra e2b-orchestrator e2b-api e2b-client-proxy || true
    echo
    curl -fsS "$ORCHESTRATOR_HEALTH" 2>/dev/null || echo "orchestrator unhealthy"
    echo
    curl -fsS "$API_HEALTH" 2>/dev/null || echo "api unhealthy"
    echo
    curl -fsS "$CLIENT_PROXY_HEALTH" 2>/dev/null || echo "client-proxy unhealthy"
    echo
    ;;
  logs)
    name="$(service_name "${2:-orchestrator}")"
    journalctl -u "$name" -f
    ;;
  *)
    usage
    exit 1
    ;;
esac
