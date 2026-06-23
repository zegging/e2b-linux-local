#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_e2b_root

cd "$E2B_ROOT"

if ! command -v gsutil >/dev/null 2>&1; then
  echo "gsutil is required for download-public-kernels/download-public-firecrackers." >&2
  echo "Install google-cloud-cli first, then rerun this script." >&2
  exit 1
fi

make download-public-kernels
make download-public-firecrackers

if make -C packages/orchestrator -n fetch-busybox BUILD_ARCH=amd64 >/dev/null 2>&1; then
  make -C packages/orchestrator fetch-busybox BUILD_ARCH=amd64
else
  mkdir -p packages/orchestrator/.busybox/1.36.1/amd64
  curl -fL --connect-timeout 20 \
    -o packages/orchestrator/.busybox/1.36.1/amd64/busybox \
    https://github.com/e2b-dev/fc-busybox/releases/download/v1.36.1/busybox_v1.36.1_amd64
  chmod +x packages/orchestrator/.busybox/1.36.1/amd64/busybox
fi

make -C packages/envd build

echo "Artifacts ready:"
ls -lah packages/fc-kernels | head
find packages/fc-versions/builds -maxdepth 4 -name firecracker -type f -exec ls -lah {} \; | head
find packages/orchestrator/.busybox -maxdepth 5 -type f -name busybox -exec ls -lah {} \;
ls -lah packages/envd/bin/envd
