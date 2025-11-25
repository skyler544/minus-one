#!/bin/bash
set -ouex pipefail

# CLEANUP
# ----------------------------------------------------
rm -rf /tmp/* || true
rm -f /var/log/dnf*.log || true
rm -rf /var/lib/dnf || true
rm -rf /var/lib/alternatives || true
