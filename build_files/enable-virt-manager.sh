#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL VIRT-MANAGER
# ----------------------------------------------------
VIRTUALIZATION_PACKAGES=(
    virt-manager
    qemu
    qemu-kvm
)
$DNF install "${VIRTUALIZATION_PACKAGES[@]}"


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


# START SERVICES
# ----------------------------------------------------
systemctl enable virtqemud.socket virtnetworkd.socket virtstoraged.socket
