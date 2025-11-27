#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL RPM FUSION
# ----------------------------------------------------
$DNF install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


# INSTALL FFMPEG
# ----------------------------------------------------
$DNF swap ffmpeg-free ffmpeg --allowerasing
