#!/bin/bash
set -ouex pipefail

# CLEANUP
# ----------------------------------------------------
# Remove all bootc lint violations
rm -rf /tmp/* || true
rm -rf /var/log/ || true
rm -rf /var/lib/dnf || true
rm -rf /var/lib/alternatives || true
rm -rf /usr/etc || true
rm -rf /boot && mkdir /boot
# Remove everything from /var/ other than caches
find /var/* -maxdepth 0 -type d \! -name cache \! -name log -exec rm -rf {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 -exec rm -rf {} \;
# Ensure tmp dir exists
mkdir -p /var/tmp
chmod -R 1777 /var/tmp
