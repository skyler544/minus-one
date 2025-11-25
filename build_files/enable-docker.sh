#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL DOCKER
# ----------------------------------------------------
$DNF config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
$DNF install --enablerepo=docker-ce-stable \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    docker-model-plugin


# START SERVICE
# ----------------------------------------------------
systemctl enable docker
