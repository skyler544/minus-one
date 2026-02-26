#!/bin/bash
set -ouex pipefail

# BOOTC
# ----------------------------------------------------
cat >/usr/lib/systemd/system/update-bootc-deployment.service <<'EOF'
[Unit]
Description=Update bootc deployment
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStartPre=/usr/sbin/bash -c 'for i in {1..60}; do getent hosts ghcr.io >/dev/null 2>&1 && exit 0 || sleep 1; done; exit 1'
ExecStart=/usr/sbin/bootc update

[Install]
WantedBy=default.target
EOF
cat >/usr/lib/systemd/system/update-bootc-deployment.timer <<'EOF'
[Unit]
Description=Update bootc deployment weekly

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# RPM-OSTREE
# ----------------------------------------------------
cat >/usr/lib/systemd/system/update-rpm-ostree-deployment.service <<'EOF'
[Unit]
Description=Update rpm-ostree deployment
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStartPre=/usr/sbin/bash -c 'for i in {1..60}; do getent hosts ghcr.io >/dev/null 2>&1 && exit 0 || sleep 1; done; exit 1'
ExecStart=/usr/sbin/rpm-ostree upgrade

[Install]
WantedBy=default.target
EOF
cat >/usr/lib/systemd/system/update-rpm-ostree-deployment.timer <<'EOF'
[Unit]
Description=Update rpm-ostree deployment weekly

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
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

# ENABLE SERVICES
# ----------------------------------------------------
systemctl enable update-bootc-deployment.timer
systemctl enable update-rpm-ostree-deployment.timer
systemctl enable update-flatpaks.timer
