#!/bin/bash
set -euxo pipefail
umask 077

DNF="dnf --quiet --assumeyes"
secret=/run/secrets/bluetooth
bluetooth_root=/run/minus-one-bluetooth

cleanup() {
    rm -rf "$bluetooth_root"
}
trap cleanup EXIT

# INTEL VIDEO ACCELERATION
# ----------------------------------------------------
$DNF install intel-media-driver
$DNF clean all
rm -rf /run/dnf

# BLUETOOTH PAIRING DATA
# ----------------------------------------------------
install --directory --owner=root --group=root --mode=0700 "$bluetooth_root"
tar --extract \
    --file "$secret" \
    --directory "$bluetooth_root" \
    --no-same-owner \
    --no-same-permissions

# INITRAMFS
# ----------------------------------------------------
/build_scripts/rebuild-initramfs \
    --add bluetooth \
    --include "$bluetooth_root" /var/lib/bluetooth
