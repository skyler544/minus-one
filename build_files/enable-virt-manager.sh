#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL VIRT-MANAGER
# ----------------------------------------------------
VIRTUALIZATION_PACKAGES=(
    qemu
    qemu-kvm
    virt-manager
)
$DNF install "${VIRTUALIZATION_PACKAGES[@]}"


# FIX GROUP
# ----------------------------------------------------
cat > /usr/lib/sysusers.d/50-libvirt.conf <<'EOF'
# Ensure libvirt/qemu groups exist
g libvirt - - - -
g qat - - - -
g qemu - - - -
u libvirt - libvirt - - - - - - Libvirt\ daemon
u qemu - qemu - - - - - - QEMU\ emulator
EOF
systemd-sysusers


# START SERVICES
# ----------------------------------------------------
systemctl enable virtqemud.socket virtnetworkd.socket virtstoraged.socket
