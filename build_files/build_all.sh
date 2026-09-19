#!/bin/bash
set -ouex pipefail

SCRIPTS=(
    setup-flatpaks.sh
    enable-docker.sh
    enable-multimedia.sh
    packages.sh
)

for s in "${SCRIPTS[@]}"; do
    bash "/build_files/$s"
done
