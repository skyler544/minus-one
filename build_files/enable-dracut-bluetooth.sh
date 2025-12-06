#!/bin/bash
set -ouex pipefail


# BLUETOOTH DROP-IN
# ----------------------------------------------------
cat > /usr/lib/dracut/dracut.conf.d/99-bluetooth.conf <<'EOF'
add_dracutmodules+=" bluetooth "
EOF


# REGENERATE INITRAMFS
# ----------------------------------------------------
kver=$(ls /usr/lib/modules); env DRACUT_NO_XATTR=1 dracut -vf /usr/lib/modules/$kver/initramfs.img "$kver"
