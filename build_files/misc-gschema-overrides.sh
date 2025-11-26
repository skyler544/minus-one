#!/bin/bash
set -ouex pipefail


# INSTALL GSCHEMA OVERRIDE
# ----------------------------------------------------
cat > /usr/share/glib-2.0/schemas/zz1-app-folders.gschema.override <<'EOF'
[org.gnome.desktop.app-folders]
folder-children=[]

[org.gnome.shell]
app-picker-layout=[]
EOF


# RECOMPILE GSCHEMAS
# ----------------------------------------------------
rm /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas
