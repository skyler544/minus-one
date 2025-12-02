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


# FIX GROUP
# ----------------------------------------------------
cat > /usr/lib/sysusers.d/50-docker.conf <<'EOF'
# Ensure docker group exists for docker.socket
g docker - - - -
EOF
systemd-sysusers


# START SERVICE
# ----------------------------------------------------
systemctl enable docker
