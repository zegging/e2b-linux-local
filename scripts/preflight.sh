#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

failures=0

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "OK   $label"
  else
    echo "FAIL $label"
    failures=$((failures + 1))
  fi
}

echo "== E2B Linux local preflight =="
print_env_summary
echo

check "E2B repo exists" test -d "$E2B_ROOT"
check "/dev/kvm exists" test -e /dev/kvm
check "/dev/net/tun exists" test -e /dev/net/tun
check "CPU virtualization flag" bash -lc "egrep -q '(vmx|svm)' /proc/cpuinfo"
check "cgroup v2" bash -lc "[ \"\$(stat -fc %T /sys/fs/cgroup)\" = cgroup2fs ]"
check "docker available" command -v docker
check "docker compose available" bash -lc "docker compose version"
check "go available" command -v go
check "node available" command -v node
check "npm available" command -v npm
check "make available" command -v make
check "curl available" command -v curl
check "jq available" command -v jq

echo
echo "Host details:"
uname -a
free -h
df -h "$E2B_ROOT" 2>/dev/null || df -h /
ls -l /dev/kvm /dev/net/tun 2>/dev/null || true

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "Preflight failed with $failures issue(s)."
  exit 1
fi

echo
echo "Preflight passed."
