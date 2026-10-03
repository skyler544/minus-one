#!/bin/bash
set -euxo pipefail

if [[ $# -ne 0 ]]; then
    echo "Usage: $0" >&2
    exit 2
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
env_file=$source_dir/.env

if [[ ! -r $env_file ]]; then
    echo "Copy .env.example to .env and set the Bluetooth addresses." >&2
    exit 1
fi

source "$env_file"
: "${BLUETOOTH_ADAPTER_ADDRESS:?Set BLUETOOTH_ADAPTER_ADDRESS in .env}"
: "${BLUETOOTH_DEVICE_ADDRESSES:?Set BLUETOOTH_DEVICE_ADDRESSES in .env}"

adapter=$BLUETOOTH_ADAPTER_ADDRESS
read -r -a devices <<<"$BLUETOOTH_DEVICE_ADDRESSES"

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

for device in "${devices[@]}"; do
    sudo install -d -m 0700 \
        "$staging/$adapter/$device"

    sudo install -m 0600 \
        "/var/lib/bluetooth/$adapter/$device/info" \
        "$staging/$adapter/$device/info"

    if sudo test -f "/var/lib/bluetooth/$adapter/$device/attributes"; then
        sudo install -m 0600 \
            "/var/lib/bluetooth/$adapter/$device/attributes" \
            "$staging/$adapter/$device/attributes"
    fi

    if sudo test -f "/var/lib/bluetooth/$adapter/cache/$device"; then
        sudo install -d -m 0700 "$staging/$adapter/cache"
        sudo install -m 0600 \
            "/var/lib/bluetooth/$adapter/cache/$device" \
            "$staging/$adapter/cache/$device"
    fi
done

sudo tar \
    --create \
    --file=/var/lib/minus-one-secrets/bluetooth.tar \
    --directory="$staging" \
    "$adapter"

sudo chown root:root /var/lib/minus-one-secrets/bluetooth.tar
sudo chmod 0600 /var/lib/minus-one-secrets/bluetooth.tar
