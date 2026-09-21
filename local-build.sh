#!/bin/bash
set -euxo pipefail

context=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_id=$(date +%s)
env_file=$context/.env

source "$env_file"
: "${MINUS_ONE_PRIMARY_USER:?Set MINUS_ONE_PRIMARY_USER in .env}"

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
    --build-arg "POLICY_USER=$MINUS_ONE_PRIMARY_USER" \
    --security-opt=label=disable \
    --secret=id=bluetooth,src=/var/lib/minus-one-secrets/bluetooth.tar \
    --file "$context/Containerfile.fynkpad" \
    --tag localhost/minus-one:latest \
    "$context"

podman image prune --force
