#!/bin/bash
set -ouex pipefail

# PREPARATION
# ----------------------------------------------------
DNF="dnf --quiet --assumeyes"

EXCLUDED_PACKAGES=(
    default-fonts-core-emoji
    fedora-flathub-remote
    fedora-third-party
    gnome-software
    gnome-software-rpm-ostree
    gnome-tour
    google-noto-color-emoji-fonts
    malcontent-control
)

INCLUDED_PACKAGES=(
    adw-gtk3-theme
    distrobox
    emacs
    wl-clipboard
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
