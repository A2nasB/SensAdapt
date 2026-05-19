# SensAdapt

Per-window mouse pointer acceleration profiles for KDE Plasma 6 (Wayland).

Automatically switches mouse sensitivity when you switch applications — no polling, no cursor glitches.

## How it works

1. **KWin Script** (`kwin/main.js`) listens for `workspace.windowActivated` and calls a DBus service
2. **Daemon** (`sensadapt-daemon`) receives the signal, matches the focused window against your configured profiles, and adjusts `pointerAcceleration` via KWin's properties
3. **GUI** (`sensadapt`) lets you create/edit profiles, capture windows, and toggle settings including auto-start and system tray

## Requirements

- KDE Plasma 6 (Wayland)
- Python 3 with `dbus` and `PyGObject` (`python3-dbus`, `python3-gobject`)

## Quick Install

```bash
git clone https://github.com/YOUR_USER/sensadapt.git
cd sensadapt
chmod +x install-sensadapt.sh
./install-sensadapt.sh
```

Then find **SensAdapt** in your app launcher or run `sensadapt`.

## Usage

1. Open **SensAdapt** from the app launcher
2. If no mouse is detected, select yours from the **Device** dropdown
3. Click **+** to add a profile:
   - Give it a name (e.g. "Firefox", "Overwatch")
   - Set the **Speed** slider
   - Click **Capture focused window** to auto-detect the active app
4. Your speed changes take effect immediately when you switch to that window

### System Tray

- **Left-click** tray icon → open/focus SensAdapt
- **Right-click** tray icon → native context menu (Open / Quit)

### Manage daemon

```bash
# View logs
journalctl --user -u sensadapt.service -f

# Stop
systemctl --user stop sensadapt.service

# Start
systemctl --user start sensadapt.service
```

## Configuration

Profiles live in `~/.config/sensadapt.json` (auto-saved from the GUI).

## Uninstall

```bash
systemctl --user stop sensadapt.service
systemctl --user disable sensadapt.service
rm -f ~/.local/bin/sensadapt ~/.local/bin/sensadapt-daemon
rm -rf ~/.local/share/kwin/scripts/sensadapt-watcher
rm -f ~/.local/share/applications/sensadapt.desktop
rm -f ~/.config/autostart/sensadapt.desktop
rm -f ~/.config/systemd/user/sensadapt.service
```

## License

GPL-3.0
