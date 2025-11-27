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
g qat - - - -
g libvirt - - - -
u qemu - qemu - - - - - - QEMU\ emulator
u libvirt - libvirt - - - - - - Libvirt\ daemon
EOF
systemd-sysusers


# FIX DIRECTORIES
# ----------------------------------------------------
cat > /usr/lib/tmpfiles.d/libvirt.conf <<'EOF'
d /var/lib/libvirt/qemu 0755 qemu qemu -
d /var/run/libvirt 0755 root root -
EOF
systemd-tmpfiles --create


# START SERVICES
# ----------------------------------------------------
systemctl enable libvirtd virtlogd virtqemud.socket virtqemud.service
