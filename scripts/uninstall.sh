#!/usr/bin/env bash
set -euo pipefail

LABEL="com.ali.nonotes"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/${LABEL}.plist"
BIN_PATH="$INSTALL_DIR/nonotes"
GUI_DOMAIN="gui/$(id -u)"

log() {
  printf '→ %s\n' "$1"
}

launchctl bootout "${GUI_DOMAIN}" "${PLIST_PATH}" >/dev/null 2>&1 || true

if [[ -f "${PLIST_PATH}" ]]; then
  log "Removing Launch Agent..."
  rm -f "${PLIST_PATH}"
fi

if [[ -f "${BIN_PATH}" ]]; then
  log "Removing binary..."
  rm -f "${BIN_PATH}"
fi

log "noNotes has been fully removed."
log "Apple Notes will work normally again."
