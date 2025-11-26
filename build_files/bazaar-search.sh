#!/bin/bash
set -ouex pipefail


# INSTALL GSCHEMA OVERRIDE
# ----------------------------------------------------
cat > /usr/lib/glib-2.0/schemas/zz0-bazaar-search.gschema.override <<'EOF'
[org.gnome.desktop.search-providers]
enabled=['io.github.kolunmi.Bazaar.desktop']
EOF


# RECOMPILE GSCHEMAS
# ----------------------------------------------------
rm /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas
