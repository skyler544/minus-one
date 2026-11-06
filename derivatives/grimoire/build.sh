#!/bin/bash
set -euxo pipefail
DNF="dnf --quiet --assumeyes"

# INTEL VIDEO ACCELERATION
# ----------------------------------------------------
$DNF install intel-media-driver

# DNF CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
rm -rf /run/dnf

# BLUETOOTH PAIRING DATA AND INITRAMFS
# ----------------------------------------------------
/build_scripts/install-bluetooth-pairing
