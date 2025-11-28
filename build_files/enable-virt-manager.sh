#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL VIRT-MANAGER
# ----------------------------------------------------
VIRTUALIZATION_PACKAGES=(
    guestfs-tools
    libguestfs
    libguestfs-xfs
    libvirt-client
    libvirt-daemon
    libvirt-daemon-config-network
    libvirt-daemon-driver-interface
    libvirt-daemon-driver-network
    libvirt-daemon-driver-nodedev
    libvirt-daemon-driver-nwfilter
    libvirt-daemon-driver-qemu
    libvirt-daemon-driver-secret
    libvirt-daemon-driver-storage-core
    libvirt-dbus
    netcat
    qemu
    qemu-img
    swtpm
    virt-install
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
