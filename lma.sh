#!/usr/bin/env bash
set -euo pipefail

# Start an interactive LMA shell with a host directory mounted at /host.
if [[ $# -eq 1 ]]; then
    docker_mount_path="$(realpath "$1")"
else
    docker_mount_path="$(pwd)"
fi

docker compose run --build --rm \
    --volume "${docker_mount_path}:/host" \
    lma-container
