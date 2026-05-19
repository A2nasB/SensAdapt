#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/YOUR_USER/sensadapt"  # <-- update this before publishing
BIN="$HOME/.local/bin"
CONFIG="$HOME/.config"
APPS="$HOME/.local/share/applications"
KWIN_SCRIPTS="$HOME/.local/share/kwin/scripts"
SYSTEMD="$HOME/.config/systemd/user"
AUTOSTART="$HOME/.config/autostart"

echo "SensAdapt Installer"
echo "==================="
echo ""

# Dependencies
echo "[1/5] Checking dependencies..."
if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not found. Install it first."
    exit 1
fi
python3 -c "import dbus, dbus.service" 2>/dev/null || {
    echo "Installing python3-dbus..."
    sudo rpm-ostree install python3-dbus
    echo "REBOOT after install completes, then re-run this script."
    exit 0
}
python3 -c "from gi.repository import GLib" 2>/dev/null || {
    echo "Installing python3-gobject..."
    sudo rpm-ostree install python3-gobject3
    echo "REBOOT after install completes, then re-run this script."
    exit 0
}
echo "  OK"

# Create directories
echo "[2/5] Creating directories..."
mkdir -p "$BIN" "$APPS" "$KWIN_SCRIPTS" "$SYSTEMD" "$AUTOSTART"

# Install binaries
echo "[3/5] Installing binaries..."
cp sensadapt "$BIN/sensadapt"
cp sensadapt-daemon "$BIN/sensadapt-daemon"
chmod +x "$BIN/sensadapt" "$BIN/sensadapt-daemon"
echo "  -> $BIN/sensadapt"
echo "  -> $BIN/sensadapt-daemon"

# Install KWin script
echo "[4/5] Installing KWin script..."
mkdir -p "$KWIN_SCRIPTS/sensadapt-watcher/contents/code"
cp kwin/metadata.json "$KWIN_SCRIPTS/sensadapt-watcher/metadata.json"
cp kwin/main.js "$KWIN_SCRIPTS/sensadapt-watcher/contents/code/main.js"

# Install desktop entry
cat > "$APPS/sensadapt.desktop" << DESKTOP_EOF
[Desktop Entry]
Name=SensAdapt
Comment=Per-window mouse sensitivity profiles
Exec=$BIN/sensadapt
Icon=preferences-desktop-mouse
Terminal=false
Type=Application
Categories=Settings;HardwareSettings;
StartupNotify=true
DESKTOP_EOF

# Install systemd service
cat > "$SYSTEMD/sensadapt.service" << SYSTEMD_EOF
[Unit]
Description=SensAdapt — per-window mouse sensitivity
After=plasma-kwin_wayland.service graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=$BIN/sensadapt-daemon
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=graphical-session.target
SYSTEMD_EOF

# Enable KWin script
echo "[5/5] Enabling..."
systemctl --user daemon-reload
systemctl --user enable --now sensadapt.service

# Load KWin script via D-Bus
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript \
    "$KWIN_SCRIPTS/sensadapt-watcher/contents/code/main.js" \
    "sensadapt-watcher" 2>/dev/null
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.start 2>/dev/null

# Enable in kwinrc
kwriteconfig6 --file kwinrc --group Plugins --key "sensadapt-watcherEnabled" "true"
qdbus org.kde.KWin /KWin reconfigure 2>/dev/null

# Rebuild app cache
kbuildsycoca6 --noincremental 2>/dev/null

echo ""
echo "SensAdapt installed!"
echo ""
echo "  Run: sensadapt"
echo "  Or find 'SensAdapt' in the app launcher"
echo ""
echo "  Edit profiles:  sensadapt"
echo "  Watch events:   journalctl --user -u sensadapt.service -f"
echo "  Stop daemon:    systemctl --user stop sensadapt.service"
