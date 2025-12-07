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
    gnome-system-monitor
    gnome-tour
    google-noto-color-emoji-fonts
    malcontent-control
    yelp
)

INCLUDED_PACKAGES=(
    adw-gtk3-theme
    ddcutil
    distrobox
    emacs
    evolution-ews-core
    tmux
)


# INSTALL PACKAGES
# ----------------------------------------------------
$DNF remove "${EXCLUDED_PACKAGES[@]}"
$DNF install "${INCLUDED_PACKAGES[@]}"


# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
