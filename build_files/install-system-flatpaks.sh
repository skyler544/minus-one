#!/bin/bash
set -ouex pipefail


# JANKY SERVICE
# ----------------------------------------------------
FLATPAKS=(
    "ca.desrt.dconf-editor"
    "com.github.tchx84.Flatseal"
    "com.mattjakeman.ExtensionManager"
    "com.ranfdev.DistroShelf"
    "io.github.celluloid_player.Celluloid"
    "io.github.fabrialberio.pinapp"
    "io.github.flattool.Ignition"
    "io.github.flattool.Warehouse"
    "io.github.kolunmi.Bazaar"
    "io.missioncenter.MissionCenter"
    "io.podman_desktop.PodmanDesktop"
    "org.gnome.Calculator"
    "org.gnome.Calendar"
    "org.gnome.Evolution"
    "org.gnome.FileRoller"
    "org.gnome.Firmware"
    "org.gnome.Logs"
    "org.gnome.Loupe"
    "org.gnome.Loupe.HEIC"
    "org.gnome.NautilusPreviewer"
    "org.gnome.Papers"
    "org.gnome.SimpleScan"
    "org.gnome.Snapshot"
    "org.gnome.SoundRecorder"
    "org.gnome.Weather"
    "org.gnome.baobab"
    "org.gnome.clocks"
    "org.gtk.Gtk3theme.adw-gtk3"
    "org.gtk.Gtk3theme.adw-gtk3-dark"
    "org.mozilla.firefox"
    "org.pipewire.Helvum"
    "page.tesk.Refine"
)
cat > /usr/lib/systemd/system/install-system-flatpaks.service <<'EOF'
[Unit]
Description=Install system flatpaks.
Wants=network-online.target
After=network-online.target replace-fedora-flatpak-remotes.service replace-installed-fedora-flatpaks.service
ConditionPathExists=!/var/lib/flatpak/.minus-one-system-flatpaks-installed

[Service]
Type=oneshot
EOF
for pkg in "${FLATPAKS[@]}"; do
    echo "ExecStart=-/usr/sbin/flatpak install --assumeyes --noninteractive $pkg" \
         >> /usr/lib/systemd/system/install-system-flatpaks.service
done
echo "ExecStartPost=/usr/sbin/touch /var/lib/flatpak/.minus-one-system-flatpaks-installed" \
     >> /usr/lib/systemd/system/install-system-flatpaks.service
cat > /usr/lib/systemd/system/install-system-flatpaks.timer <<'EOF'
[Unit]
Description=Run install-system-flatpaks after connecting to the network after first boot.

[Timer]
OnBootSec=2min
Persistent=yes

[Install]
WantedBy=timers.target
EOF


# ENABLE SERVICE
# ----------------------------------------------------
systemctl enable install-system-flatpaks.timer
