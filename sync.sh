#!/usr/bin/env bash
# Copies kit/ into a widget as <widget>/kit/ and stamps the kit version.
# Marketplace plugins are installed from their own repository, so each widget
# carries its copy; this keeps the copies identical.
#   ./sync.sh ~/.config/omarchy/plugins/ismoil.rtk
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
[ $# -ge 1 ] || { echo "usage: sync.sh <widget-dir>..." >&2; exit 2; }
for dest in "$@"; do
  [ -f "$dest/manifest.json" ] || { echo "$dest is not a plugin folder (no manifest.json)" >&2; exit 1; }
  rm -rf "$dest/kit"
  mkdir -p "$dest/kit"
  cp "$here"/kit/* "$dest/kit/"
  cp "$here/VERSION" "$dest/kit/VERSION"
  echo "kit $(cat "$here/VERSION") -> $dest/kit"
done
