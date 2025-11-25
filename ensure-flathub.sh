#!/bin/bash
set -ouex pipefail

# ENABLE FLATHUB
# ----------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo \
     "/etc/flatpak/remotes.d/flathub.flatpakrepo" \
     "https://dl.flathub.org/repo/flathub.flatpakrepo"


# OVERWRITE SERVICE
# ----------------------------------------------------
mv -f /usr/lib/systemd/system/flatpak-add-flathub-repos.service \
   /usr/lib/systemd/system/flatpak-add-fedora-repos.service || true

cat > /usr/lib/systemd/system/flatpak-add-flathub-repos.service <<'EOF'
[Unit]
Description=Add Flathub flatpak repositories.
ConditionPathExists=!/var/lib/flatpak/.minus-one-flatpak-initialized
Before=flatpak-system-helper.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/flatpak remote-add --system --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
ExecStart=/usr/bin/flatpak remote-add --system --if-not-exists --disable --title "Fedora Flatpaks" fedora oci+https://registry.fedoraproject.org
ExecStart=/usr/bin/flatpak remote-add --system --if-not-exists --disable --title "Fedora Flatpaks (testing)" fedora oci+https://registry.fedoraproject.org#testing
ExecStartPost=/usr/bin/touch /var/lib/flatpak/.minus-one-flatpak-initialized

[Install]
WantedBy=multi-user.target
EOF
