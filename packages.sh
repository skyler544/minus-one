#!/bin/bash

# PREPARATION
# ----------------------------------------------------
set -ouex pipefail

DNF="dnf --quiet --assumeyes"

EXCLUDED_PACKAGES=(
    default-fonts-core-emoji
    gnome-tour
    google-noto-color-emoji-fonts
    malcontent-control
)

INCLUDED_PACKAGES=(
    emacs
)


# PACKAGES
# ----------------------------------------------------
$DNF remove "${EXCLUDED_PACKAGES[@]}"
$DNF install "${INCLUDED_PACKAGES[@]}"


# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
rm -f /var/log/dnf*.log
rm -rf /var/lib/dnf
rm -rf /var/lib/alternatives
