#!/bin/bash
set -ouex pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run bootstrap.sh as root." >&2
    exit 1
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

config=$(mktemp /etc/minus-one-build.conf.new.XXXXXX)
printf 'MINUS_ONE_SOURCE=%s\n' "$source_dir" >"$config"
chmod 0644 "$config"
mv "$config" /etc/minus-one-build.conf

"$source_dir/local-build.sh"

podman image inspect \
    --format 'Image ID: {{.Id}} Architecture: {{.Architecture}}' \
    localhost/minus-one:latest

bootc switch \
    --transport containers-storage \
    localhost/minus-one:latest

echo "The machine image is staged. Reboot when ready."
