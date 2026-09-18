#!/usr/bin/env bash
set -euo pipefail

# Icons for the options
ICON_LOCK="🔒"
ICON_LOGOUT="🚪"
ICON_SUSPEND="💤"
ICON_REBOOT="🔄"
ICON_SHUTDOWN="⏻"

# Options list
OPTIONS="$ICON_LOCK Lock\n$ICON_LOGOUT Logout\n$ICON_SUSPEND Suspend\n$ICON_REBOOT Reboot\n$ICON_SHUTDOWN Shutdown"

# Rofi invocation
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 20em;} listview {lines: 5;}')

case "$CHOICE" in
    *Lock)
        # Lock screen
        hyprlock
        ;;
    *Logout)
        # Confirm and logout
        CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -i -p "Confirm Logout" -theme-str 'window {width: 15em;} listview {lines: 2;}')
        if [[ "$CONFIRM" == "Yes" ]]; then
            hyprctl dispatch exit
        fi
        ;;
    *Suspend)
        # Confirm and suspend
        CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -i -p "Confirm Suspend" -theme-str 'window {width: 15em;} listview {lines: 2;}')
        if [[ "$CONFIRM" == "Yes" ]]; then
            systemctl suspend
        fi
        ;;
    *Reboot)
        # Confirm and reboot
        CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -i -p "Confirm Reboot" -theme-str 'window {width: 15em;} listview {lines: 2;}')
        if [[ "$CONFIRM" == "Yes" ]]; then
            systemctl reboot
        fi
        ;;
    *Shutdown)
        # Confirm and shutdown
        CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -i -p "Confirm Shutdown" -theme-str 'window {width: 15em;} listview {lines: 2;}')
        if [[ "$CONFIRM" == "Yes" ]]; then
            systemctl poweroff
        fi
        ;;
esac
