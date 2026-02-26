#!/bin/bash
set -ouex pipefail

# SIGSTORE FILES
# ----------------------------------------------------
cat >/usr/lib/minus-one/sigstore/ghcr.io.yaml <<'EOF'
docker:
  ghcr.io/skyler544:
    use-sigstore-attachments: true
EOF

cat >/usr/lib/minus-one/sigstore/policy.json <<'EOF'
{
  "default": [
    {
      "type": "reject"
    }
  ],
  "transports": {
    "docker": {
      "ghcr.io/skyler544": [
        {
          "type": "sigstoreSigned",
          "keyPath": "/etc/pki/containers/minus-one.pub",
          "signedIdentity": {
            "type": "matchRepository"
          }
        }
      ],
      "": [
        {
          "type": "insecureAcceptAnything"
        }
      ]
    },
    "docker-daemon": {
      "": [
        {
          "type": "insecureAcceptAnything"
        }
      ]
    }
  }
}
EOF

# INSTALL SIGSTORE CONFIG FILES
# ----------------------------------------------------
cat >/usr/lib/systemd/system/enable-signed-registries.service <<'EOF'
[Unit]
Description=Install sigstore key and container registry policy for signed images.
Wants=network-online.target
After=network-online.target
ConditionPathExists=!/var/lib/.minus-one-signed-registries-initialized

[Service]
Type=oneshot
ExecStart=/usr/sbin/mkdir -p /etc/pki/containers /etc/containers/registries.d
ExecStart=/usr/sbin/cp /usr/lib/minus-one/sigstore/minus-one.pub /etc/pki/containers/
ExecStart=/usr/sbin/cp /usr/lib/minus-one/sigstore/ghcr.io.yaml /etc/containers/registries.d/
ExecStart=/usr/sbin/cp /usr/lib/minus-one/sigstore/policy.json /etc/containers/policy.json
ExecStart=-/usr/sbin/restorecon -RFv /etc/pki/containers /etc/containers/registries.d
ExecStartPost=/usr/sbin/touch /var/lib/.minus-one-signed-registries-initialized

[Install]
WantedBy=multi-user.target
EOF

# ENABLE SERVICE
# ----------------------------------------------------
systemctl enable enable-signed-registries.service
