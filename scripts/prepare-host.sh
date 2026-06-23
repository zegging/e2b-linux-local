#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

modprobe nbd nbds_max=64 || true

cat >/etc/modules-load.d/nbd.conf <<'EOF'
nbd nbds_max=64
EOF

cat >/etc/sysctl.d/99-e2b-local.conf <<'EOF'
vm.nr_hugepages=2048
net.ipv4.ip_forward=1
EOF

cat >/etc/sysctl.d/98-e2b-userfaultfd.conf <<'EOF'
vm.unprivileged_userfaultfd=1
EOF

sysctl -w vm.nr_hugepages=2048
sysctl -w net.ipv4.ip_forward=1
sysctl -w vm.unprivileged_userfaultfd=1 || true

echo "Host runtime prepared."
grep HugePages /proc/meminfo || true
sysctl net.ipv4.ip_forward || true
sysctl vm.unprivileged_userfaultfd || true
