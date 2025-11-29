#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL VIRT-MANAGER
# ----------------------------------------------------
VIRTUALIZATION_PACKAGES=(
    libvirt-daemon
    libvirt-daemon-config-network
    libvirt-daemon-driver-interface
    libvirt-daemon-driver-network
    libvirt-daemon-driver-nwfilter
    libvirt-daemon-driver-qemu
    libvirt-daemon-driver-secret
    libvirt-daemon-driver-storage-core
    qemu-kvm
)
$DNF install "${VIRTUALIZATION_PACKAGES[@]}"


# START SERVICES
# ----------------------------------------------------
systemctl enable virtqemud.socket virtnetworkd.socket virtstoraged.socket
