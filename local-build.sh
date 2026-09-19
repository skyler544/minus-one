#!/bin/bash
set -ouex pipefail

context=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

podman build \
    --pull=always \
    --no-cache \
    --security-opt=label=disable \
    --tag localhost/minus-one-base:latest \
    "$context"
