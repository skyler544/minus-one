#!/bin/bash
set -euxo pipefail
DNF="dnf --quiet --assumeyes"

# BASE PACKAGES
# ----------------------------------------------------
EXCLUDED_PACKAGES=(
    default-fonts-core-emoji
    fedora-bookmarks
    fedora-chromium-config
    fedora-chromium-config-gnome
    fedora-flathub-remote
    fedora-third-party
    firefox
    firefox-langpacks
    gnome-shell-extension-apps-menu
    gnome-shell-extension-background-logo
    gnome-shell-extension-launch-new-instance
    gnome-shell-extension-places-menu
    gnome-shell-extension-window-list
    gnome-software
    gnome-software-rpm-ostree
    gnome-system-monitor
    gnome-tour
    google-noto-color-emoji-fonts
    malcontent-control
    open-vm-tools-desktop
    spice-vdagent
    virtualbox-guest-additions
    yelp
)

INCLUDED_PACKAGES=(
    adw-gtk3-theme
    ddcutil
    distrobox
    emacs
    google-noto-fonts-all
    papirus-icon-theme
    podman-compose
)

$DNF install "${INCLUDED_PACKAGES[@]}"
$DNF remove "${EXCLUDED_PACKAGES[@]}"

# DOCKER
# ----------------------------------------------------
$DNF config-manager addrepo \
    --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

DOCKER_PACKAGES=(
    containerd.io
    docker-ce
    docker-ce-cli
    docker-compose-plugin
)

$DNF install --enablerepo=docker-ce-stable "${DOCKER_PACKAGES[@]}"

systemd-sysusers
systemctl enable docker.socket

# NIX
# ----------------------------------------------------
NIX_PACKAGES=(
    nix
    nix-daemon
)

$DNF install "${NIX_PACKAGES[@]}"

systemctl enable nix-daemon.socket nix.mount
rm -rf /nix
mkdir -p /nix

cat >>/etc/selinux/targeted/contexts/files/file_contexts.subs_dist <<'EOF'
/nix/store /usr
/nix/var /run
/var/nix/store /usr
/var/nix/var /run
EOF

# MULTIMEDIA
# ----------------------------------------------------
$DNF install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

$DNF swap ffmpeg-free ffmpeg --allowerasing
$DNF group install multimedia \
    --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin

MULTIMEDIA_PACKAGES=(
    ImageMagick-heic
    libheif-freeworld
    libheif-tools
    libva-utils
)

$DNF install --allow-downgrade --allowerasing "${MULTIMEDIA_PACKAGES[@]}"

# DNF CLEANUP
# ----------------------------------------------------
$DNF autoremove && $DNF clean all
rm -rf /run/dnf

# FLATPAKS
# ----------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo \
    "/etc/flatpak/remotes.d/flathub.flatpakrepo" \
    "https://dl.flathub.org/repo/flathub.flatpakrepo"

rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service || true
systemctl enable replace-fedora-flatpak-remotes.service
systemctl enable replace-installed-fedora-flatpaks.timer

systemctl enable update-flatpaks.timer
systemctl enable install-system-flatpaks.timer

# SYSTEM SERVICES
# ----------------------------------------------------
systemctl enable minus-one-build.timer
systemctl enable rebuild-mandb.timer

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
