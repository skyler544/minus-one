#!/bin/bash
set -ouex pipefail

# SERVICES
# ----------------------------------------------------
systemctl enable flatpak-add-flathub-repos.service


# CLEANUP
# ----------------------------------------------------
rm -rf /tmp/* || true
ostree container commit
