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
# fix for bluetooth bug, remove me when this package makes it to stable
# $DNF upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2026-293c809594
# even with the advisory, emacs / firefox crashes when switching headset profiles
$DNF downgrade wireplumber wireplumber-libs


# CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
