#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# PACKAGE LISTS
# ----------------------------------------------------
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
    ddcutil
    distrobox
    emacs
    gnome-tweaks
    virt-manager
)


# INSTALL PACKAGES
# ----------------------------------------------------
$DNF remove "${EXCLUDED_PACKAGES[@]}"
$DNF install "${INCLUDED_PACKAGES[@]}"


# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
