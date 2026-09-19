#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"

# RPM Fusion
# ----------------------------------------------------
$DNF install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Multimedia
# ----------------------------------------------------
$DNF swap ffmpeg-free ffmpeg --allowerasing
$DNF install libheif-tools libheif-freeworld ImageMagick-heic
$DNF group install multimedia \
    --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
