#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# PACKAGE LISTS
# ----------------------------------------------------
EXCLUDED_PACKAGES=(
    default-fonts-core-emoji
    fedora-bookmarks
    fedora-chromium-config
    fedora-chromium-config-gnome
    fedora-flathub-remote
    fedora-third-party
    firefox
    firefox-langpacks
    gnome-shell-extension-apps-menu
    gnome-shell-extension-background-logo
    gnome-shell-extension-launch-new-instance
    gnome-shell-extension-places-menu
    gnome-shell-extension-window-list
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

# https://bodhi.fedoraproject.org/updates/FEDORA-2026-293c809594
# bluetooth fix
$DNF clean all && $DNF install https://kojipkgs.fedoraproject.org//packages/gnome-shell/48.7/3.fc42/x86_64/gnome-shell-48.7-3.fc42.x86_64.rpm


# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
