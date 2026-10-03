#!/bin/bash
set -euxo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 KEYBOARD_ADDRESS..." >&2
    exit 2
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
env_file=$source_dir/.env

if [[ ! -r $env_file ]]; then
    echo "Copy .env.example to .env and set the adapter address." >&2
    exit 1
fi

source "$env_file"
: "${BLUETOOTH_ADAPTER_ADDRESS:?Set BLUETOOTH_ADAPTER_ADDRESS in .env}"

adapter=$BLUETOOTH_ADAPTER_ADDRESS

sudo install -d -o root -g root -m 0700 \
    /var/lib/minus-one-secrets

staging=$(sudo mktemp -d /var/lib/minus-one-secrets/bluetooth.XXXXXX)

cleanup() {
    sudo rm -rf -- "$staging"
}
trap cleanup EXIT

sudo install -d -m 0700 \
    "$staging/$adapter"

sudo install -m 0600 \
    "/var/lib/bluetooth/$adapter/settings" \
    "$staging/$adapter/settings"

for keyboard in "$@"; do
    sudo install -d -m 0700 \
        "$staging/$adapter/$keyboard"

    sudo install -m 0600 \
        "/var/lib/bluetooth/$adapter/$keyboard/info" \
        "$staging/$adapter/$keyboard/info"

    if sudo test -f "/var/lib/bluetooth/$adapter/$keyboard/attributes"; then
        sudo install -m 0600 \
            "/var/lib/bluetooth/$adapter/$keyboard/attributes" \
            "$staging/$adapter/$keyboard/attributes"
    fi

    if sudo test -f "/var/lib/bluetooth/$adapter/cache/$keyboard"; then
        sudo install -d -m 0700 "$staging/$adapter/cache"
        sudo install -m 0600 \
            "/var/lib/bluetooth/$adapter/cache/$keyboard" \
            "$staging/$adapter/cache/$keyboard"
    fi
done

sudo tar \
    --create \
    --file=/var/lib/minus-one-secrets/bluetooth.tar \
    --directory="$staging" \
    "$adapter"

sudo chown root:root /var/lib/minus-one-secrets/bluetooth.tar
sudo chmod 0600 /var/lib/minus-one-secrets/bluetooth.tar
