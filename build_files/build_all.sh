#!/bin/bash
set -ouex pipefail

SCRIPTS=(
    ensure-flathub.sh
    install-system-flatpaks.sh
    automatic-updates.sh
    enable-docker.sh
    enable-ha-drivers.sh
    enable-virt-manager.sh
    packages.sh
    cleanup.sh
)

for s in "${SCRIPTS[@]}"; do
    bash "/build_files/$s"
done
