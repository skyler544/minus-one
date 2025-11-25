#!/bin/bash
set -ouex pipefail

# SERVICES
# ----------------------------------------------------
systemctl enable flatpak-add-flathub-repos.service
systemctl enable flatpak-system-update.timer


# CLEANUP
# ----------------------------------------------------
rm -rf /tmp/* || true
ostree container commit
