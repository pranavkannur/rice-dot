#!/usr/bin/env bash
set -euo pipefail

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="screenshot_$(date +'%Y%m%d_%H%M%S').png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

MODE="${1:-area}"

case "$MODE" in
    full)
        grim "$FILEPATH"
        ;;
    area)
        grim -g "$(slurp)" "$FILEPATH"
        ;;
    window)
        # Capture active window
        ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [[ -n "$ACTIVE_WINDOW" ]]; then
            grim -g "$ACTIVE_WINDOW" "$FILEPATH"
        else
            grim -g "$(slurp)" "$FILEPATH"
        fi
        ;;
    *)
        echo "Usage: $0 [full | area | window]"
        exit 1
        ;;
esac

# Copy to clipboard
if command -v wl-copy &> /dev/null; then
    wl-copy < "$FILEPATH"
fi

# Annotate with swappy if available
if command -v swappy &> /dev/null; then
    swappy -f "$FILEPATH"
fi

# Notify
if command -v notify-send &> /dev/null; then
    notify-send "Screenshot Captured" "Saved to $FILEPATH" -i "$FILEPATH"
fi

echo "Screenshot saved to $FILEPATH"
