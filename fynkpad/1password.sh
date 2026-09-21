#!/bin/bash
#
# caveat lector: this script is 100% AI-generated. It installs 1password.
set -euxo pipefail

DNF="dnf --quiet --assumeyes"
ONEPASSWORD_KEY_URL="https://downloads.1password.com/linux/keys/1password.asc"
: "${POLICY_USER:?Pass POLICY_USER as a build argument}"

# GROUPS
# ----------------------------------------------------
groupadd -g 1500 onepassword
groupadd -g 1501 onepassword-cli
groupadd -g 1502 onepassword-mcp

cat >/usr/lib/sysusers.d/50-1password.conf <<'EOF'
g onepassword     1500
g onepassword-cli 1501
g onepassword-mcp 1502
EOF
chmod 0644 /usr/lib/sysusers.d/50-1password.conf

# REPOSITORY
# ----------------------------------------------------
rpm --import "$ONEPASSWORD_KEY_URL"
cat >/etc/yum.repos.d/1password.repo <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
chmod 0644 /etc/yum.repos.d/1password.repo

# INSTALL
# ----------------------------------------------------
mkdir -p /var/opt
$DNF install 1password 1password-cli

if [ -d /var/opt/1Password ]; then
    mv /var/opt/1Password /usr/lib/1Password
else
    mv /opt/1Password /usr/lib/1Password
fi
rm -rf /var/opt

echo 'L /opt/1Password - - - - ../../usr/lib/1Password' >/usr/lib/tmpfiles.d/1password.conf
chmod 0644 /usr/lib/tmpfiles.d/1password.conf

ln -sf /usr/lib/1Password/1password /usr/bin/1password
ln -sf /usr/lib/1Password/1password-mcp /usr/bin/1password-mcp

# POLKIT ACTION
# ----------------------------------------------------
(
    cd /usr/lib/1Password
    export POLICY_OWNERS="unix-user:${POLICY_USER}"
    eval "cat <<EOF
$(cat ./com.1password.1Password.policy.tpl)
EOF" >/usr/share/polkit-1/actions/com.1password.1Password.policy
)
chmod 0644 /usr/share/polkit-1/actions/com.1password.1Password.policy
