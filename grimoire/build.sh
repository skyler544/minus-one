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
install --directory --mode=1777 /var/tmp
install --directory --mode=0700 /var/roothome
install --directory --mode=1777 /tmp/dracut

mapfile -t kernels < <(
    find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
)
kernel=${kernels[0]}
initramfs=/usr/lib/modules/$kernel/initramfs.img

DRACUT_NO_XATTR=1 dracut \
    --force \
    --rebuild "$initramfs" \
    --add bluetooth \
    --include "$bluetooth_root" /var/lib/bluetooth \
    "$initramfs" \
    "$kernel"
