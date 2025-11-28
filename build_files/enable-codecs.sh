#!/bin/bash
set -ouex pipefail
DNF="dnf --quiet --assumeyes"


# INSTALL RPM FUSION
# ----------------------------------------------------
$DNF install \
     https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
     https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


# INSTALL FFMPEG
# ----------------------------------------------------
$DNF swap ffmpeg-free ffmpeg --allowerasing


# UPDATE CODECS
# ----------------------------------------------------
CODEC_PACKAGES=(
    fdk-aac
    gstreamer1-libav
    gstreamer1-plugin-dav1d
    gstreamer1-plugin-openh264
    gstreamer1-plugins-bad-freeworld
    gstreamer1-plugins-ugly
    lame
    libaom
    libavcodec-freeworld
    libdvdcss
    libopus
    libtheora
    libvorbis
    libvpx
    libwebp
    openh264
    x264
    x265
)
$DNF install "${CODEC_PACKAGES[@]}"


# UPDATE DRIVERS
# ----------------------------------------------------
$DNF install intel-media-driver libva-intel-media-driver
$DNF swap mesa-va-drivers mesa-va-drivers-freeworld
$DNF swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
