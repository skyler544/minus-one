#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL VIRT-MANAGER
# ----------------------------------------------------
$DNF install @virtualization


# FIX GROUP
# ----------------------------------------------------
cat > /usr/lib/sysusers.d/50-libvirt.conf <<'EOF'
# Ensure virt group exists
g libvirt - - - -
EOF
systemd-sysusers


# START SERVICE
# ----------------------------------------------------
systemctl enable libvirtd
