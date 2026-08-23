#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

IMAGE="${FIRE_OPS_IMAGE:-fire_ops:dp}"

echo "[build] ${IMAGE}"
docker build -f src/docker/Dockerfile -t "${IMAGE}" "$@" ./src
echo "[build] done"
docker images "${IMAGE}" --format 'table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}'
