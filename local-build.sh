#!/bin/bash
set -ouex pipefail

context=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_id=$(date +%s)

podman build \
    --pull=always \
    --build-arg "MINUS_ONE_BUILD_ID=$build_id" \
    --security-opt=label=disable \
    --tag localhost/minus-one-base:latest \
    "$context"

podman image prune --force
