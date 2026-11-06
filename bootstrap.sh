#!/bin/bash
set -euxo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run bootstrap.sh as root." >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 --base|--DERIVATIVE" >&2
    exit 2
fi

image=${1#--}
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

if [[ $image != base && ! -f $source_dir/derivatives/$image/build.sh ]]; then
    echo "Unknown derivative: $image" >&2
    exit 2
fi

config=$(mktemp /etc/minus-one-build.conf.new.XXXXXX)
printf 'MINUS_ONE_SOURCE=%s\n' "$source_dir" >"$config"
printf 'MINUS_ONE_IMAGE=%s\n' "$image" >>"$config"
chmod 0644 "$config"
mv "$config" /etc/minus-one-build.conf

"$source_dir/local-build.sh" "--$image"

bootc_status=$(bootc status --format=json | tr -d '[:space:]')
host_spec=${bootc_status#*'"spec":'}
host_spec=${host_spec%%,'"status":'*}
local_image='"image":{"image":"localhost/minus-one:latest","transport":"containers-storage"}'

if [[ $host_spec == *"$local_image"* ]]; then
    bootc upgrade
else
    bootc switch \
        --transport containers-storage \
        localhost/minus-one:latest
fi

echo "The image is staged. Reboot when ready."
