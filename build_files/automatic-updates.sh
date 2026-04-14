#!/bin/bash
set -ouex pipefail

# RPM-OSTREE
# ----------------------------------------------------
cat >/usr/lib/systemd/system/configure-rpm-ostree-autoupdate.service <<'EOF'
[Unit]
Description=Configure rpm-ostree automatic updates
After=network-online.target
ConditionPathExists=!/etc/rpm-ostreed.conf.d/.autoupdate-configured

[Service]
Type=oneshot
ExecStart=/usr/sbin/bash -c "sed -i 's/#AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf"
ExecStartPost=/usr/sbin/touch /var/lib/rpm-ostree/.minus-one-autoupdate-configured

[Install]
WantedBy=multi-user.target
EOF

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
ExecStart=/usr/sbin/flatpak repair
ExecStart=/usr/sbin/flatpak uninstall --assumeyes --unused --noninteractive
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
systemctl enable configure-rpm-ostree-autoupdate.service
systemctl enable update-flatpaks.timer
