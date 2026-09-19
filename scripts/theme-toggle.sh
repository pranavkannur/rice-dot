#!/usr/bin/env bash
set -euo pipefail

# Cache directory and state files
CACHE_DIR="$HOME/.cache/rice_dot"
MODE_FILE="$CACHE_DIR/theme_mode"
WALLPAPER_FILE="$CACHE_DIR/current_wallpaper"

mkdir -p "$CACHE_DIR"

# Read current mode, default to dark
if [[ -f "$MODE_FILE" ]]; then
    CURRENT_MODE=$(cat "$MODE_FILE")
else
    CURRENT_MODE="dark"
fi

# Toggle mode
if [[ "$CURRENT_MODE" == "dark" ]]; then
    NEW_MODE="light"
else
    NEW_MODE="dark"
fi

# Save new mode
echo "$NEW_MODE" > "$MODE_FILE"

# Get current wallpaper
if [[ -f "$WALLPAPER_FILE" ]]; then
    WALLPAPER=$(cat "$WALLPAPER_FILE")
else
    # Fallback to swww/awww query if available, parse first output
    SWWW_BIN="swww"
    command -v swww &>/dev/null || SWWW_BIN="awww"
    WALLPAPER=$("$SWWW_BIN" query 2>/dev/null | head -n 1 | awk -F 'image: ' '{print $2}')
fi

if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
    # Run matugen if available
    if command -v matugen &> /dev/null; then
        matugen image "$WALLPAPER" -m "$NEW_MODE" --source-color-index 0
    fi
fi

# Update GTK color scheme
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$NEW_MODE"
fi

# Reload Waybar
if pgrep -x waybar &> /dev/null; then
    killall -SIGUSR2 waybar || true
fi

# Reload SwayNC
if command -v swaync-client &> /dev/null; then
    swaync-client -rs || true
fi

# Reload Kitty colors
if pgrep -x kitty &> /dev/null; then
    kitty @ --to unix:/tmp/kitty-socket set-colors --all ~/.config/kitty/colors.conf || true
fi

# Sync VS Code theme
VSCODE_CONFIG="$HOME/.config/Code/User/settings.json"
if [[ -f "$VSCODE_CONFIG" ]]; then
    if [[ "$NEW_MODE" == "dark" ]]; then
        sed -i 's/"workbench.colorTheme": "[^"]*"/"workbench.colorTheme": "Catppuccin Mocha"/' "$VSCODE_CONFIG" 2>/dev/null || true
        sed -i 's/"workbench.iconTheme": "[^"]*"/"workbench.iconTheme": "catppuccin-mocha"/' "$VSCODE_CONFIG" 2>/dev/null || true
    else
        sed -i 's/"workbench.colorTheme": "[^"]*"/"workbench.colorTheme": "Catppuccin Latte"/' "$VSCODE_CONFIG" 2>/dev/null || true
        sed -i 's/"workbench.iconTheme": "[^"]*"/"workbench.iconTheme": "catppuccin-latte"/' "$VSCODE_CONFIG" 2>/dev/null || true
    fi
fi

# Send notification
if command -v notify-send &> /dev/null; then
    notify-send "Theme" "Switched to $NEW_MODE mode" -i preferences-desktop-theme
fi

echo "Successfully switched to $NEW_MODE mode."
