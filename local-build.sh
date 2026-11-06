#!/bin/bash
set -euxo pipefail

context=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_id=$(date +%s)

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 --base|--DERIVATIVE" >&2
    exit 2
fi

# prevent old images from filling up the container storage
cleanup() {
    podman image prune --force || true
}
trap cleanup EXIT

image=${1#--}
if [[ $image != base && ! -f $context/derivatives/$image/build.sh ]]; then
    echo "Unknown derivative: $image" >&2
    exit 2
fi

common_build_options=(
    --force-rm
    --network=host
    --build-arg "MINUS_ONE_BUILD_ID=$build_id"
    --security-opt=label=disable
)

base_build_options=(
    "${common_build_options[@]}"
    --pull=always
    --tag localhost/minus-one-base:latest
)

podman build "${base_build_options[@]}" "$context"

if [[ $image == base ]]; then
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

    derivative_build_options=(
        "${common_build_options[@]}"
        --pull=never
        --build-arg "MINUS_ONE_DERIVATIVE=$image"
        --build-arg MINUS_ONE_PRIMARY_USER
        --file "$context/Containerfile.derivative"
        --tag localhost/minus-one:latest
    )

    bluetooth_secret=/var/lib/minus-one-secrets/bluetooth.tar
    if [[ -f $bluetooth_secret ]]; then
        derivative_build_options+=(--secret=id=bluetooth,src="$bluetooth_secret")
    fi

    podman build "${derivative_build_options[@]}" "$context"
fi
