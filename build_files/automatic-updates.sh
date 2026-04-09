#!/bin/bash
set -ouex pipefail

# FLATPAK
# ----------------------------------------------------
cat >/usr/lib/systemd/system/update-flatpaks.service <<'EOF'
[Unit]
Description=Update Flatpaks
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStartPre=/usr/sbin/bash -c 'for i in {1..60}; do getent hosts ghcr.io >/dev/null 2>&1 && exit 0 || sleep 1; done; exit 1'
ExecStart=/usr/sbin/flatpak update --assumeyes --noninteractive

[Install]
WantedBy=default.target
EOF
cat >/usr/lib/systemd/system/update-flatpaks.timer <<'EOF'
[Unit]
Description=Update Flatpaks daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# ENABLE SERVICE
# ----------------------------------------------------
systemctl enable update-flatpaks.timer
