#!/bin/bash
set -euxo pipefail

context=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_id=$(date +%s)

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 --base|--MACHINE" >&2
    exit 2
fi

machine=${1#--}
containerfile=$context/Containerfile.$machine
if [[ $machine != base && ! -f $containerfile ]]; then
    echo "Unknown machine: $machine" >&2
    exit 2
fi

podman build \
    --pull=always \
    --build-arg "MINUS_ONE_BUILD_ID=$build_id" \
    --security-opt=label=disable \
    --tag localhost/minus-one-base:latest \
    "$context"

if [[ $machine == base ]]; then
    podman tag \
        localhost/minus-one-base:latest \
        localhost/minus-one:latest
else
    env_file=$context/.env
    if [[ -r $env_file ]]; then
        set -a
        source "$env_file"
        set +a
    fi

    machine_build_options=(
        --pull=never
        --network=host
        --build-arg "MINUS_ONE_BUILD_ID=$build_id"
        --build-arg MINUS_ONE_PRIMARY_USER
        --security-opt=label=disable
        --file "$containerfile"
        --tag localhost/minus-one:latest
    )

    bluetooth_secret=/var/lib/minus-one-secrets/bluetooth.tar
    if [[ -f $bluetooth_secret ]]; then
        machine_build_options+=(--secret=id=bluetooth,src="$bluetooth_secret")
    fi

    podman build "${machine_build_options[@]}" "$context"
fi

# prevent old images from filling up the rootful container storage
podman image prune --force
