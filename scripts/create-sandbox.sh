#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

timeout_seconds="${1:-3600}"
template_id="${2:-base}"

if [[ "$E2B_API_KEY" == "<LOCAL_DEV_API_KEY>" ]]; then
  echo "Set E2B_API_KEY in $ENV_FILE before creating sandboxes." >&2
  exit 1
fi

curl -s -X POST "http://127.0.0.1:3000/sandboxes" \
  -H "X-API-Key: $E2B_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"templateID\":\"$template_id\",\"timeout\":$timeout_seconds}" | jq
