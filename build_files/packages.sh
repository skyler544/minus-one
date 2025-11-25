#!/bin/bash
set -ouex pipefail

# PREPARATION
# ----------------------------------------------------
DNF="dnf --quiet --assumeyes"

EXCLUDED_PACKAGES=(
    default-fonts-core-emoji
    fedora-flathub-remote
    fedora-third-party
    firefox
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
    google-noto-emoji-fonts
    wl-clipboard
)


# PACKAGES
# ----------------------------------------------------
$DNF remove "${EXCLUDED_PACKAGES[@]}"
$DNF install "${INCLUDED_PACKAGES[@]}"


# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
