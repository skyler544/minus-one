#!/bin/bash
set -ouex pipefail


# FLATHUB REPO
# ----------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo \
     "/etc/flatpak/remotes.d/flathub.flatpakrepo" \
     "https://dl.flathub.org/repo/flathub.flatpakrepo"


# REPLACE FEDORA FLATPAK REMOTES
# ----------------------------------------------------
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service || true
cat > /usr/lib/systemd/system/replace-fedora-flatpak-remotes.service <<'EOF'
[Unit]
Description=Add Flathub flatpak remotes and remove Fedora flatpak remotes.
ConditionPathExists=!/var/lib/flatpak/.minus-one-flatpak-initialized
Before=flatpak-system-helper.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=-/usr/bin/flatpak remote-delete --force fedora
ExecStart=-/usr/bin/flatpak remote-delete --force fedora-testing
ExecStart=/usr/bin/flatpak remote-add --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
ExecStart=/usr/bin/flatpak remote-modify --enable flathub
ExecStartPost=/usr/bin/touch /var/lib/flatpak/.minus-one-flatpak-initialized

[Install]
WantedBy=multi-user.target
EOF


# REPLACE FEDORA FLATPAKS
# ----------------------------------------------------
cat > /usr/lib/systemd/system/replace-installed-fedora-flatpaks.service <<'EOF'
[Unit]
Description=Replace all installed Fedora flatpaks with Flathub versions.
Wants=network-online.target
After=network-online.target replace-fedora-flatpak-remotes.service
ConditionPathExists=!/var/lib/flatpak/.minus-one-flatpaks-replaced

[Service]
Type=oneshot
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --reinstall --noninteractive --assumeyes flathub $(/usr/bin/flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1)'
ExecStartPost=/usr/bin/touch /var/lib/flatpak/.minus-one-flatpaks-replaced
EOF
cat > /usr/lib/systemd/system/replace-installed-fedora-flatpaks.timer <<'EOF'
[Unit]
Description=Run replace-fedora-flatpaks after connecting to the network after first boot.

[Timer]
OnBootSec=1min
Persistent=yes

[Install]
WantedBy=timers.target
EOF


# ENABLE SERVICES
# ----------------------------------------------------
systemctl enable replace-fedora-flatpak-remotes.service
systemctl enable replace-installed-fedora-flatpaks.timer
