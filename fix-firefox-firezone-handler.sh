#!/bin/bash
#
# caveat lector: this script is 100% AI-generated. Before running it, logging in
# to firezone from flatpak firefox was impossible.
#
# Usage: ./fix-firefox-firezone-handler.sh [SCHEME] SCHEME defaults to
#   firezone-fd0020211111. it's the x-scheme-handler/... in
#   ~/.local/share/applications/firezone-client.desktop
set -euxo pipefail

APP_ID="org.mozilla.firefox"
SCHEME="${1:-firezone-fd0020211111}"
CLIENT_BIN="/usr/bin/firezone-client-gui"
DESKTOP_ID="firezone-deeplink.desktop"

DATA_DIR="$HOME/.var/app/$APP_ID/data"
CONFIG_DIR="$HOME/.var/app/$APP_ID/config"
APPS_DIR="$DATA_DIR/applications"
DESKTOP_FILE="$APPS_DIR/$DESKTOP_ID"
MIMEAPPS="$CONFIG_DIR/mimeapps.list"
MIMECACHE="$APPS_DIR/mimeinfo.cache"

echo ">> Target scheme: x-scheme-handler/$SCHEME"
echo ">> Firefox flatpak: $APP_ID"

# --- 1. allow Firefox to spawn host processes --------------------------------
echo ">> Granting host-spawn permission (org.freedesktop.Flatpak talk name)"
flatpak override --user --talk-name=org.freedesktop.Flatpak "$APP_ID"

# --- 2. sandbox-visible handler that bridges to the host binary --------------
echo ">> Writing handler: $DESKTOP_FILE"
mkdir -p "$APPS_DIR"
cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Firezone deep link (host)
Exec=/usr/bin/flatpak-spawn --host $CLIENT_BIN open-deep-link %u
MimeType=x-scheme-handler/$SCHEME;
NoDisplay=true
Terminal=false
EOF

# --- 3. make it the default handler inside the sandbox -----------------------
echo ">> Setting default association in: $MIMEAPPS"
mkdir -p "$CONFIG_DIR"
touch "$MIMEAPPS"
awk -v scheme="$SCHEME" -v desktop="$DESKTOP_ID" '
  /^\[Default Applications\]/ {
    print
    print "x-scheme-handler/" scheme "=" desktop
    added = 1
    next
  }
  $0 ~ ("^x-scheme-handler/" scheme "=") { next }   # drop any stale line
  { print }
  END {
    if (!added) {
      print "[Default Applications]"
      print "x-scheme-handler/" scheme "=" desktop
    }
  }
' "$MIMEAPPS" >"$MIMEAPPS.tmp" && mv "$MIMEAPPS.tmp" "$MIMEAPPS"

# --- 4. discovery cache (so Firefox can list the app by MIME type) -----------
echo ">> Updating MIME cache: $MIMECACHE"
if [ -f "$MIMECACHE" ]; then
    # merge: drop any old line for this scheme, ensure ours is present
    awk -v scheme="$SCHEME" -v desktop="$DESKTOP_ID" '
    /^\[MIME Cache\]/ { print; print "x-scheme-handler/" scheme "=" desktop ";"; added=1; next }
    $0 ~ ("^x-scheme-handler/" scheme "=") { next }
    { print }
    END { if (!added) { print "[MIME Cache]"; print "x-scheme-handler/" scheme "=" desktop ";" } }
  ' "$MIMECACHE" >"$MIMECACHE.tmp" && mv "$MIMECACHE.tmp" "$MIMECACHE"
else
    cat >"$MIMECACHE" <<EOF
[MIME Cache]
x-scheme-handler/$SCHEME=$DESKTOP_ID;
EOF
fi

echo
echo ">> Done. Verify the permission stuck:"
echo "   flatpak info --show-permissions $APP_ID | grep -i flatpak"
echo
echo ">> Smoke-test the sandbox -> host bridge (expect 'Opening deep-link' +"
echo "   an 'account_slug' parse line in the newest gui-client log):"
echo "   flatpak run --command=sh $APP_ID -c \\"
echo "     '/usr/bin/flatpak-spawn --host $CLIENT_BIN open-deep-link \\"
echo "      \"$SCHEME://handle_client_sign_in_callback?state=test&account_slug=test&actor_name=test&fragment=test&identity_provider_identifier=test\"'"
echo
echo ">> Then sign in from the tray. On the first real prompt, pick"
echo "   'Firezone deep link (host)' and check Remember."
