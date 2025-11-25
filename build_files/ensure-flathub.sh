#!/bin/bash
set -ouex pipefail


# FLATHUB REPO
# ----------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo \
     "/etc/flatpak/remotes.d/flathub.flatpakrepo" \
     "https://dl.flathub.org/repo/flathub.flatpakrepo"


# OVERWRITE SERVICE
# ----------------------------------------------------
rm -f /usr/lib/systemd/system/flatpak-add-flathub-repos.service || true
cat > /usr/lib/systemd/system/flatpak-add-flathub-repos.service <<'EOF'
[Unit]
Description=Add Flathub flatpak repositories and replace all Fedora flatpaks.
ConditionPathExists=!/var/lib/flatpak/.minus-one-flatpak-initialized
Before=flatpak-system-helper.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/flatpak remote-delete --force fedora
ExecStart=/usr/bin/flatpak remote-delete --force fedora-testing
ExecStart=/usr/bin/flatpak remote-add --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
ExecStart=/usr/bin/flatpak remote-modify --enable flathub
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --reinstall --assumeyes flathub $(/usr/bin/flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1)'
ExecStartPost=/usr/bin/touch /var/lib/flatpak/.minus-one-flatpak-initialized

[Install]
WantedBy=multi-user.target
EOF


# START SERVICE
# ----------------------------------------------------
systemctl enable flatpak-add-flathub-repos.service
