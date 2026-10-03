#!/bin/bash
set -euxo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run bootstrap.sh as root." >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 --base|--MACHINE" >&2
    exit 2
fi

machine=${1#--}
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

if [[ $machine != base && ! -f $source_dir/Containerfile.$machine ]]; then
    echo "Unknown machine: $machine" >&2
    exit 2
fi

config=$(mktemp /etc/minus-one-build.conf.new.XXXXXX)
printf 'MINUS_ONE_SOURCE=%s\n' "$source_dir" >"$config"
printf 'MINUS_ONE_MACHINE=%s\n' "$machine" >>"$config"
chmod 0644 "$config"
mv "$config" /etc/minus-one-build.conf

"$source_dir/local-build.sh" "--$machine"

image=containers-storage:localhost/minus-one:latest
booted_image=$(bootc status | sed -n 's/^.*Booted image: //p')

if [[ $booted_image == "$image" ]]; then
    bootc upgrade
else
    bootc switch \
        --transport containers-storage \
        localhost/minus-one:latest
fi

echo "The machine image is staged. Reboot when ready."
