#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"

# INSTALL DOCKER
# ----------------------------------------------------
DOCKER_PACKAGES=(
    containerd.io
    docker-ce
    docker-ce-cli
    docker-compose-plugin
)
$DNF config-manager addrepo \
    --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
$DNF install --enablerepo=docker-ce-stable "${DOCKER_PACKAGES[@]}"

systemd-sysusers

# START SERVICE
# ----------------------------------------------------
systemctl enable docker.socket
