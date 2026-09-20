#!/bin/bash
set -euxo pipefail
DNF="dnf --quiet --assumeyes"

# FLATHUB REPO
# ----------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo \
    "/etc/flatpak/remotes.d/flathub.flatpakrepo" \
    "https://dl.flathub.org/repo/flathub.flatpakrepo"

# REPLACE FEDORA FLATPAKS
# ----------------------------------------------------
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service || true
systemctl enable replace-fedora-flatpak-remotes.service
systemctl enable replace-installed-fedora-flatpaks.timer

# AUTOMATIC UPDATES
# ----------------------------------------------------
systemctl enable update-flatpaks.timer
systemctl enable install-system-flatpaks.timer
systemctl enable minus-one-build.timer

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

# START DOCKER SOCKET
# ----------------------------------------------------
systemctl enable docker.socket

# RPM FUSION
# ----------------------------------------------------
$DNF install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# MULTIMEDIA
# ----------------------------------------------------
$DNF swap ffmpeg-free ffmpeg --allowerasing
$DNF install libheif-tools libheif-freeworld ImageMagick-heic
$DNF group install multimedia \
    --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
