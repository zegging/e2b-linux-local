#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

apt-get update
apt-get install -y \
  git curl wget unzip jq make build-essential pkg-config \
  ca-certificates gnupg lsb-release software-properties-common \
  cpu-checker qemu-utils bridge-utils iptables nftables \
  postgresql-client redis-tools \
  golang-go nodejs npm

echo "Dependencies installed. Docker, Packer, Terraform, and gsutil may still need separate installation depending on host state."
