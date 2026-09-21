#!/bin/bash
set -euxo pipefail

context=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_id=$(date +%s)

podman build \
    --pull=always \
    --network=host \
    --build-arg "MINUS_ONE_BUILD_ID=$build_id" \
    --security-opt=label=disable \
    --tag localhost/minus-one-base:latest \
    "$context"

podman build \
    --pull=never \
    --network=host \
    --build-arg "MINUS_ONE_BUILD_ID=$build_id" \
    --security-opt=label=disable \
    --secret=id=bluetooth,src=/var/lib/minus-one-secrets/bluetooth.tar \
    --file "$context/Containerfile.grimoire" \
    --tag localhost/minus-one:latest \
    "$context"

podman image prune --force
