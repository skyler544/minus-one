#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL RPM FUSION
# ----------------------------------------------------
$DNF install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


# UPDATE DRIVERS
# ----------------------------------------------------
$DNF install intel-media-driver
$DNF swap mesa-va-drivers mesa-va-drivers-freeworld
