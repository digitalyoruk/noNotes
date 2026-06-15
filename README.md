# noNotes

**Block Apple Notes on macOS.**

As a Mac user, I hate when default Apple apps get forced on me: opening on their own, hijacking Bluetooth events, showing up when I never asked. **noNotes** is a tiny native background daemon that kills Apple Notes the moment it tries to open. No polling. No bash loops. It sits at 0% CPU until macOS wakes it up. Inspired by [noTunes](https://github.com/tombonez/noTunes).

---

## Quick install

One command. No dependencies beyond Apple's built-in Command Line Tools.

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/digitalyoruk/noNotes@main/scripts/install.sh | bash
```

That's it. Notes is blocked. It survives reboots automatically.

---

## What it does

- Kills Apple Notes the moment it tries to launch
- Kills Notes if it's already running when noNotes starts
- Blocks switching to Notes if it somehow stays alive
- Starts at login via a Launch Agent
- Uses ~0% CPU and ~2.5 MB RAM

## What it does not do

- Remove Notes from Spotlight, Dock, or System Settings
- Block Quick Notes or widget surfaces (only the main `com.apple.Notes` app)

---

## Installation

### Option 1: One-line install (recommended)

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/digitalyoruk/noNotes@main/scripts/install.sh | bash
```

### Option 2: Clone and install

```bash
git clone https://github.com/digitalyoruk/noNotes.git
cd noNotes
./scripts/install.sh
```

### Option 3: Make

```bash
git clone https://github.com/digitalyoruk/noNotes.git
cd noNotes
make install
```

### Prerequisites

You need Apple's Command Line Tools:

```bash
xcode-select --install
```

---

## Verify it works

After installing, try opening Notes:

```bash
open -a Notes
```

Notes should flash and disappear. Check that the daemon is running:

```bash
launchctl list | grep nonotes
```

You should see `com.ali.nonotes` with a PID.

---

## Uninstall

### If you installed from the repo

```bash
cd noNotes
./scripts/uninstall.sh
```

### If you only ran the one-liner

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/digitalyoruk/noNotes@main/scripts/uninstall.sh | bash
```

### Manual removal

```bash
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/com.ali.nonotes.plist
rm ~/Library/LaunchAgents/com.ali.nonotes.plist
rm ~/.local/bin/nonotes
```

After uninstalling, Apple Notes works normally again.

---

## How it works

noNotes uses macOS's native `NSWorkspace` API to listen for app launch and activation events.

```
macOS launches an app
        ↓
NSWorkspace sends a notification
        ↓
noNotes checks the bundle ID
        ↓
com.apple.Notes? → forceTerminate()
```

No polling. The process sleeps until macOS wakes it up.

---

## File locations

After install, these files exist on your Mac:

| Path | Purpose |
|------|---------|
| `~/.local/bin/nonotes` | Compiled daemon |
| `~/Library/LaunchAgents/com.ali.nonotes.plist` | Auto-start config |
| `/tmp/nonotes.log` | stdout log |
| `/tmp/nonotes.err` | stderr log |

**To stop noNotes permanently**, delete the Launch Agent plist. Without it, noNotes will not come back after reboot.

---

## Build from source

```bash
git clone https://github.com/digitalyoruk/noNotes.git
cd noNotes
make build
./build/nonotes
```

The binary is written to `build/nonotes`. Press `Ctrl+C` to stop it when running manually.

---

## Troubleshooting

**Install fails with "clang not found"**

```bash
xcode-select --install
```

**Install fails with Swift/SDK errors**

noNotes uses Objective-C (`clang`), not Swift. You do not need Xcode, only Command Line Tools.

**Notes still opens briefly**

That is expected. `forceTerminate()` runs within milliseconds of launch. A brief flash is normal.

**Check if the daemon is alive**

```bash
launchctl print "gui/$(id -u)/com.ali.nonotes"
pgrep -fl nonotes
cat /tmp/nonotes.err
```

**Restart the daemon**

```bash
launchctl kickstart -k "gui/$(id -u)/com.ali.nonotes"
```

---

## Author

**Ali**

---

## License

MIT. See [LICENSE](LICENSE).
