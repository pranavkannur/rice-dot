#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="$HOME/.cache/rice_dot"
MODE_FILE="$CACHE_DIR/theme_mode"
WALLPAPER_FILE="$CACHE_DIR/current_wallpaper"
WALLPAPERS_DIR="$HOME/rice_dot/assets/wallpapers"

mkdir -p "$CACHE_DIR"
mkdir -p "$WALLPAPERS_DIR"

show_usage() {
    echo "Usage: $0 [path-to-image | --random | --select]"
    exit 1
}

if [[ $# -eq 0 ]]; then
    show_usage
fi

ACTION="$1"
WALLPAPER=""

if [[ "$ACTION" == "--random" ]]; then
    # Pick a random wallpaper
    WALLPAPER=$(find "$WALLPAPERS_DIR" -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.jpeg \) | shuf -n 1 || true)
elif [[ "$ACTION" == "--select" ]]; then
    # Use rofi to select
    if command -v rofi &> /dev/null; then
        BASENAME=$(find "$WALLPAPERS_DIR" -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.jpeg \) -exec basename {} \; | rofi -dmenu -p "Select Wallpaper")
        if [[ -n "$BASENAME" ]]; then
            WALLPAPER="$WALLPAPERS_DIR/$BASENAME"
        else
            exit 0
        fi
    else
        echo "Rofi is not installed."
        exit 1
    fi
elif [[ -f "$ACTION" ]]; then
    WALLPAPER=$(realpath "$ACTION")
else
    echo "Error: Invalid argument or file not found."
    show_usage
fi

if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    echo "No valid wallpaper found."
    exit 1
fi

# Ensure wallpaper daemon (swww or awww) is running
SWWW_BIN="swww"
SWWW_DAEMON="swww-daemon"
if ! command -v swww &>/dev/null && command -v awww &>/dev/null; then
    SWWW_BIN="awww"
    SWWW_DAEMON="awww-daemon"
fi

if ! pgrep -x "$SWWW_DAEMON" &> /dev/null && ! pgrep -x "swww-daemon" &> /dev/null && ! pgrep -x "awww-daemon" &> /dev/null; then
    "$SWWW_DAEMON" &
    sleep 1
fi

# Set the wallpaper
"$SWWW_BIN" img "$WALLPAPER" --transition-type grow --transition-pos center --transition-duration 1.5 --transition-fps 60

# Save to cache
echo "$WALLPAPER" > "$WALLPAPER_FILE"

# Read theme mode
MODE="dark"
if [[ -f "$MODE_FILE" ]]; then
    MODE=$(cat "$MODE_FILE")
fi

# Run matugen
if command -v matugen &> /dev/null; then
    matugen image "$WALLPAPER" -m "$MODE"
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

# Notification
if command -v notify-send &> /dev/null; then
    notify-send "Wallpaper set: $(basename "$WALLPAPER")" -i "$WALLPAPER"
fi

echo "Wallpaper set to $WALLPAPER"
