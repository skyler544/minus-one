#!/bin/bash
set -euxo pipefail
DNF="dnf --quiet --assumeyes"

FIREZONE_VERSION=1.5.19
FIREZONE_RPM=firezone-client-gui-linux_${FIREZONE_VERSION}_x86_64.rpm
FIREZONE_URL=https://github.com/firezone/firezone/releases/download/gui-client-${FIREZONE_VERSION}/${FIREZONE_RPM}

# AMD VIDEO ACCELERATION
# ----------------------------------------------------
$DNF install mesa-va-drivers-freeworld

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

# DNF CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
rm -rf /run/dnf

# BLUETOOTH PAIRING DATA AND INITRAMFS
# ----------------------------------------------------
/build_scripts/install-bluetooth-pairing
