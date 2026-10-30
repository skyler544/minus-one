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
systemctl enable rebuild-mandb.timer

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
$DNF install --allow-downgrade --allowerasing \
    libheif-tools libheif-freeworld ImageMagick-heic
$DNF group install multimedia \
    --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin
$DNF install libva-utils

# NIX
# ----------------------------------------------------
$DNF install nix nix-daemon
systemctl enable nix-daemon.socket nix.mount
rm -rf /nix
mkdir -p /nix

cat >>/etc/selinux/targeted/contexts/files/file_contexts.subs_dist <<'EOF'
/nix/store /usr
/nix/var /run
/var/nix/store /usr
/var/nix/var /run
EOF

# PLYMOUTH
# ----------------------------------------------------
# Hide ugly LUKS unlock text
# https://discussion.fedoraproject.org/t/please-enter-passphrase-for-disk-has-returned/150626
populate_initrd=/usr/libexec/plymouth/plymouth-populate-initrd
label_freetype_check='if [ -f "${PLYMOUTH_PLUGIN_PATH}/label-freetype.so" ]; then'
grep --quiet --fixed-strings "$label_freetype_check" "$populate_initrd"
sed --in-place "s|^${label_freetype_check//[/\\[}\$|if false; then|" "$populate_initrd"
grep --quiet --line-regexp 'if false; then' "$populate_initrd"

# INITRAMFS
# ----------------------------------------------------
install --directory --mode=1777 /var/tmp
install --directory --mode=0700 /var/roothome
install --directory --mode=1777 /tmp/dracut

mapfile -t kernels < <(
    find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
)
kernel=${kernels[0]}
initramfs=/usr/lib/modules/$kernel/initramfs.img

DRACUT_NO_XATTR=1 dracut \
    --force \
    --rebuild "$initramfs" \
    "$initramfs" \
    "$kernel"
