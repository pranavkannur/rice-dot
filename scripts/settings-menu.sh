#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/rice_dot"
WALLPAPER_DIR="$DOTFILES_DIR/assets/wallpapers"
HYPR_VARS="$HOME/.config/hypr/hypr-vars.conf"
CACHE_DIR="$HOME/.cache/rice_dot"

# Ensure directories and files exist before operating on them
mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$HYPR_VARS")"
touch "$HYPR_VARS"

update_hypr_var() {
    local var="$1" value="$2"
    if grep -q "^\$$var = " "$HYPR_VARS"; then
        sed -i "s/^\$$var = .*$/\$$var = $value/" "$HYPR_VARS"
    else
        echo "\$$var = $value" >> "$HYPR_VARS"
    fi
}

declare -a options=(
    "1. 🖼 Change Wallpaper"
    "2. 🌗 Toggle Dark/Light Mode"
    "3. 🔲 Window Opacity"
    "4. 🌫 Blur Intensity"
    "5. ⚡ Animation Speed"
    "6. 👥 Window Shadows"
    "7. 🔒 VPN Controls"
    "8. 🌐 DNS Settings"
    "9. 🔊 Audio Settings"
)

choice=$(printf "%s\n" "${options[@]}" | rofi -dmenu -i -p "Settings")

case "$choice" in
    "1. 🖼 Change Wallpaper")
        if [ -d "$WALLPAPER_DIR" ]; then
            selected_wallpaper=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | rofi -dmenu -i -p "Select Wallpaper")
            if [ -n "$selected_wallpaper" ]; then
                "$DOTFILES_DIR/scripts/wallpaper.sh" "$WALLPAPER_DIR/$selected_wallpaper"
            fi
        else
            rofi -e "Wallpaper directory not found: $WALLPAPER_DIR"
        fi
        ;;
        
    "2. 🌗 Toggle Dark/Light Mode")
        "$DOTFILES_DIR/scripts/theme-toggle.sh"
        ;;
        
    "3. 🔲 Window Opacity")
        op_choice=$(printf "100%%\n95%%\n92%%\n90%%\n85%%\n80%%\n75%%\n70%%\n" | rofi -dmenu -i -p "Opacity")
        if [ -n "$op_choice" ]; then
            # Convert percentage string to float
            act_op=$(echo "$op_choice" | sed 's/%//' | awk '{print $1/100}')
            # Inactive opacity is 0.08 lower, with a minimum of 0.1
            inact_op=$(awk -v ao="$act_op" 'BEGIN { io = ao - 0.08; print (io < 0.1) ? 0.1 : io }')
            
            update_hypr_var "active_opacity" "$act_op"
            update_hypr_var "inactive_opacity" "$inact_op"
            
            hyprctl keyword decoration:active_opacity "$act_op"
            hyprctl keyword decoration:inactive_opacity "$inact_op"
        fi
        ;;
        
    "4. 🌫 Blur Intensity")
        blur_choice=$(printf "Off\nLight\nMedium\nHeavy\n" | rofi -dmenu -i -p "Blur Intensity")
        case "$blur_choice" in
            "Off") size=0; passes=0 ;;
            "Light") size=4; passes=1 ;;
            "Medium") size=8; passes=2 ;;
            "Heavy") size=12; passes=3 ;;
            *) exit 0 ;;
        esac
        
        update_hypr_var "blur_size" "$size"
        update_hypr_var "blur_passes" "$passes"
        
        hyprctl keyword decoration:blur:size "$size"
        hyprctl keyword decoration:blur:passes "$passes"
        
        if [ "$blur_choice" = "Off" ]; then
            hyprctl keyword decoration:blur:enabled false
        else
            hyprctl keyword decoration:blur:enabled true
        fi
        ;;
        
    "5. ⚡ Animation Speed")
        anim_choice=$(printf "Fast\nBalanced\nSmooth\nOff\n" | rofi -dmenu -i -p "Animation Speed")
        case "$anim_choice" in
            "Fast")
                update_hypr_var "anim_enabled" "true"
                update_hypr_var "anim_speed" "2"
                hyprctl keyword animations:enabled true
                hyprctl keyword animation "windows,1,2,myBezier"
                hyprctl keyword animation "windowsOut,1,2,smoothOut,popin 80%"
                hyprctl keyword animation "fade,1,2,smoothIn"
                hyprctl keyword animation "workspaces,1,2,default"
                ;;
            "Balanced")
                update_hypr_var "anim_enabled" "true"
                update_hypr_var "anim_speed" "4"
                hyprctl keyword animations:enabled true
                hyprctl keyword animation "windows,1,4,myBezier"
                hyprctl keyword animation "windowsOut,1,4,smoothOut,popin 80%"
                hyprctl keyword animation "fade,1,4,smoothIn"
                hyprctl keyword animation "workspaces,1,4,default"
                ;;
            "Smooth")
                update_hypr_var "anim_enabled" "true"
                update_hypr_var "anim_speed" "7"
                hyprctl keyword animations:enabled true
                hyprctl keyword animation "windows,1,7,myBezier"
                hyprctl keyword animation "windowsOut,1,7,smoothOut,popin 80%"
                hyprctl keyword animation "fade,1,7,smoothIn"
                hyprctl keyword animation "workspaces,1,7,default"
                ;;
            "Off")
                update_hypr_var "anim_enabled" "false"
                update_hypr_var "anim_speed" "0"
                hyprctl keyword animations:enabled false
                ;;
            *) exit 0 ;;
        esac
        ;;
        
    "6. 👥 Window Shadows")
        shadow_choice=$(printf "Enable Shadows\nDisable Shadows\n" | rofi -dmenu -i -p "Shadows")
        case "$shadow_choice" in
            "Enable Shadows")
                update_hypr_var "shadow_enabled" "true"
                hyprctl keyword decoration:shadow:enabled true
                ;;
            "Disable Shadows")
                update_hypr_var "shadow_enabled" "false"
                hyprctl keyword decoration:shadow:enabled false
                ;;
            *) exit 0 ;;
        esac
        ;;
        
    "7. 🔒 VPN Controls")
        vpn_list=$(nmcli -t -f NAME,TYPE,STATE connection show | awk -F: '$2=="vpn" || $2=="wireguard" {print $1 " (" $3 ")"}')
        if [ -z "$vpn_list" ]; then
            rofi -e "No VPN configured"
            exit 0
        fi
        
        vpn_choice=$(echo "$vpn_list" | rofi -dmenu -i -p "VPN Controls")
        if [ -n "$vpn_choice" ]; then
            vpn_name=$(echo "$vpn_choice" | sed 's/ (.*)//')
            vpn_state=$(echo "$vpn_choice" | grep -o "(.*)")
            
            if [[ "$vpn_state" == "(activated)" ]]; then
                nmcli connection down "$vpn_name"
            else
                nmcli connection up "$vpn_name"
            fi
        fi
        ;;
        
    "8. 🌐 DNS Settings")
        dns_choice=$(printf "Cloudflare\nAdGuard\nQuad9\nGoogle\nAutomatic\n" | rofi -dmenu -i -p "DNS Settings")
        if [ -n "$dns_choice" ]; then
            active_conn=$(nmcli -t -f NAME,DEVICE connection show --active | head -n 1 | cut -d':' -f1)
            
            case "$dns_choice" in
                "Cloudflare") dns_addr="1.1.1.1 1.0.0.1" ;;
                "AdGuard") dns_addr="94.140.14.14 94.140.15.15" ;;
                "Quad9") dns_addr="9.9.9.9 149.112.112.112" ;;
                "Google") dns_addr="8.8.8.8 8.8.4.4" ;;
                "Automatic") dns_addr="" ;;
            esac
            
            if [ "$dns_choice" = "Automatic" ]; then
                nmcli connection modify "$active_conn" ipv4.dns "" ipv4.ignore-auto-dns no
            else
                nmcli connection modify "$active_conn" ipv4.dns "$dns_addr" ipv4.ignore-auto-dns yes
            fi
            
            nmcli connection up "$active_conn"
        fi
        ;;
        
    "9. 🔊 Audio Settings")
        pavucontrol &
        ;;
esac
