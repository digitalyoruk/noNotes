#!/usr/bin/env bash
set -euo pipefail

LABEL="com.ali.nonotes"
REPO="https://github.com/digitalyoruk/noNotes"
RAW="https://cdn.jsdelivr.net/gh/digitalyoruk/noNotes@main"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/${LABEL}.plist"
BIN_PATH="$INSTALL_DIR/nonotes"
GUI_DOMAIN="gui/$(id -u)"

log() {
  printf '→ %s\n' "$1"
}

err() {
  printf '✗ %s\n' "$1" >&2
  exit 1
}

if ! xcode-select -p >/dev/null 2>&1; then
  err "Xcode Command Line Tools are required. Run: xcode-select --install"
fi

if ! command -v clang >/dev/null 2>&1; then
  err "clang not found. Install Xcode Command Line Tools: xcode-select --install"
fi

SOURCE_FILE=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  SOURCE_FILE="${ROOT_DIR}/src/nonotes.m"
fi
BUILD_DIR="$(mktemp -d)"
TMP_DIR=""
trap 'rm -rf "${BUILD_DIR}" "${TMP_DIR}"' EXIT

if [[ ! -f "${SOURCE_FILE}" ]]; then
  log "Downloading source from ${REPO}..."
  TMP_DIR="$(mktemp -d)"
  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 "${REPO}.git" "${TMP_DIR}/noNotes"
    SOURCE_FILE="${TMP_DIR}/noNotes/src/nonotes.m"
  else
    mkdir -p "${TMP_DIR}/src"
    curl -fsSL "${RAW}/src/nonotes.m" -o "${TMP_DIR}/src/nonotes.m"
    SOURCE_FILE="${TMP_DIR}/src/nonotes.m"
  fi
fi

if [[ ! -f "${SOURCE_FILE}" ]]; then
  err "Could not find nonotes.m. Clone the repo manually: git clone ${REPO}.git"
fi

log "Building noNotes..."
mkdir -p "${INSTALL_DIR}" "${LAUNCH_AGENTS_DIR}"
clang -Wall -Wextra -O2 -framework Foundation -framework AppKit \
  -o "${BUILD_DIR}/nonotes" "${SOURCE_FILE}"

log "Installing binary to ${BIN_PATH}"
install -m 755 "${BUILD_DIR}/nonotes" "${BIN_PATH}"

log "Installing Launch Agent..."
cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${BIN_PATH}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/nonotes.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/nonotes.err</string>
</dict>
</plist>
EOF

launchctl bootout "${GUI_DOMAIN}" "${PLIST_PATH}" >/dev/null 2>&1 || true
launchctl bootstrap "${GUI_DOMAIN}" "${PLIST_PATH}"

if launchctl print "${GUI_DOMAIN}/${LABEL}" >/dev/null 2>&1; then
  log "noNotes is running and will start automatically at login."
else
  err "Launch Agent failed to start. Check /tmp/nonotes.err for details."
fi

cat <<'EOF'

✓ Installation complete.

Apple Notes is now blocked in the background.
Try opening Notes. It should close immediately.

To remove noNotes later:
  curl -fsSL https://cdn.jsdelivr.net/gh/digitalyoruk/noNotes@main/scripts/uninstall.sh | bash

EOF
