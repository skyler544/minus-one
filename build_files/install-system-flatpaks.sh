#!/bin/bash
set -ouex pipefail


# JANKY SERVICE
# ----------------------------------------------------
cat > /usr/lib/systemd/system/install-system-flatpaks.service <<'EOF'
[Unit]
Description=Install system flatpaks.
Wants=network-online.target
After=network-online.target replace-fedora-flatpak-remotes.service replace-installed-fedora-flatpaks.service
ConditionPathExists=!/var/lib/flatpak/.minus-one-system-flatpaks-installed

[Service]
Type=oneshot
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive ca.desrt.dconf-editor'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive com.github.tchx84.Flatseal'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive com.mattjakeman.ExtensionManager'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive com.ranfdev.DistroShelf'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.github.celluloid_player.Celluloid'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.github.fabrialberio.pinapp'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.github.flattool.Ignition'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.github.flattool.Warehouse'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.github.kolunmi.Bazaar'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.github.vikdevelop.SaveDesktop'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.missioncenter.MissionCenter'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive io.podman_desktop.PodmanDesktop'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Calculator'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Calendar'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Evolution'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.FileRoller'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Firmware'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Logs'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Loupe'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Loupe.HEIC'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.NautilusPreviewer'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Papers'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.SimpleScan'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Snapshot'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.SoundRecorder'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.Weather'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.baobab'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gnome.clocks'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gtk.Gtk3theme.adw-gtk3'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.gtk.Gtk3theme.adw-gtk3-dark'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.mozilla.firefox'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive org.pipewire.Helvum'
ExecStart=-/bin/bash -c '/usr/bin/flatpak install --assumeyes --noninteractive page.tesk.Refine'
ExecStartPost=/usr/bin/touch /var/lib/flatpak/.minus-one-system-flatpaks-installed
EOF
cat > /usr/lib/systemd/system/install-system-flatpaks.timer <<'EOF'
[Unit]
Description=Run install-system-flatpaks after connecting to the network after first boot.

[Timer]
OnBootSec=2min
Unit=install-system-flatpaks.service
Persistent=yes

[Install]
WantedBy=timers.target
EOF


# ENABLE SERVICE
# ----------------------------------------------------
systemctl enable install-system-flatpaks.timer
