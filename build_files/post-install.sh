#!/bin/bash
set -ouex pipefail

# SERVICES
# ----------------------------------------------------
systemctl enable flatpak-add-flathub-repos.service
systemctl enable docker.socket


# CLEANUP
# ----------------------------------------------------
rm -rf /tmp/* || true
rm -f /var/log/dnf*.log || true
rm -rf /var/lib/dnf || true
rm -rf /var/lib/alternatives || true

ostree container commit
