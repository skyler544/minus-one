#!/bin/bash
set -ouex pipefail

# FLATHUB REPO
# ----------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo \
    "/etc/flatpak/remotes.d/flathub.flatpakrepo" \
    "https://dl.flathub.org/repo/flathub.flatpakrepo"

# REPLACE FEDORA FLATPAKS
# ----------------------------------------------------
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service || true
systemctl enable replace-fedora-flatpak-remotes.service
systemctl enable replace-installed-fedora-flatpaks.timer

# AUTOMATIC UPDATES
# ----------------------------------------------------
systemctl enable update-flatpaks.timer
systemctl enable install-system-flatpaks.timer
