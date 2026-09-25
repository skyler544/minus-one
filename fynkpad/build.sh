#!/bin/bash
set -euxo pipefail
umask 077

DNF="dnf --quiet --assumeyes"
secret=/run/secrets/bluetooth
bluetooth_root=/run/minus-one-bluetooth

FIREZONE_VERSION=1.5.17
FIREZONE_RPM=firezone-client-gui-linux_${FIREZONE_VERSION}_x86_64.rpm
FIREZONE_URL=https://github.com/firezone/firezone/releases/download/gui-client-${FIREZONE_VERSION}/${FIREZONE_RPM}

cleanup() {
    rm -rf "$bluetooth_root"
}
trap cleanup EXIT

# AMD VIDEO ACCELERATION
# ----------------------------------------------------
$DNF install mesa-va-drivers-freeworld
$DNF clean all

# FIREZONE
# ----------------------------------------------------
$DNF install libappindicator-gtk3

curl --retry 3 --location --fail --output "/tmp/$FIREZONE_RPM" "$FIREZONE_URL"
$DNF install --setopt=tsflags=noscripts "/tmp/$FIREZONE_RPM"
rm -f "/tmp/$FIREZONE_RPM"

systemctl enable firezone-client-tunnel.service

# 1PASSWORD
# ----------------------------------------------------
bash /build_scripts/1password.sh

# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
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
