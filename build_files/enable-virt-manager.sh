#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL VIRT-MANAGER
# ----------------------------------------------------
$DNF install @virtualization


# FIX GROUP
# ----------------------------------------------------
cat > /usr/lib/sysusers.d/50-libvirt.conf <<'EOF'
# Ensure libvirt/qemu groups exist
g qemu - - - -
g libvirt - - - -
u qemu - qemu - - - - - - QEMU\ emulator
u libvirt - libvirt - - - - - - Libvirt\ daemon
EOF
systemd-sysusers


# START SERVICES
# ----------------------------------------------------
systemctl enable libvirtd virtlogd virtqemud.socket virtqemud.service
