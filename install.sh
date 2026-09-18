#!/usr/bin/env bash
set -euo pipefail

info() { echo -e "\e[34m[INFO]\e[0m $1"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
warn() { echo -e "\e[33m[WARN]\e[0m $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m $1"; exit 1; }

# Step 1: Check if running on Arch Linux
if [[ ! -f /etc/os-release ]] || ! grep -q "ID=arch" /etc/os-release; then
    warn "This script is intended for Arch Linux. Your system might not be supported, but we will try anyway."
fi

# Step 2: Check for pacman
if ! command -v pacman &> /dev/null; then
    error "pacman not found. Are you on Arch Linux?"
fi

# Step 3: Check for yay
if ! command -v yay &> /dev/null; then
    info "yay not found. Installing yay from AUR..."
    read -p "Do you want to install yay? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        (cd /tmp/yay-bin && makepkg -si --noconfirm)
        rm -rf /tmp/yay-bin
        success "yay installed."
    else
        error "yay is required for AUR packages. Aborting."
    fi
fi

# Step 4: Install pacman packages
if [[ -f packages/pacman-packages.txt ]]; then
    info "Installing pacman packages..."
    grep -v '^#' packages/pacman-packages.txt | grep -v '^$' | xargs -r sudo pacman -S --needed --noconfirm
fi

# Step 5: Install AUR packages
if [[ -f packages/aur-packages.txt ]]; then
    info "Installing AUR packages..."
    grep -v '^#' packages/aur-packages.txt | grep -v '^$' | xargs -r yay -S --needed --noconfirm
fi

# Step 6: Deploy symlinks
info "Deploying configuration files..."
./scripts/deploy.sh

# Step 7: Set Zsh as default shell
if ! grep -q "zsh$" <<< "$SHELL"; then
    info "Changing default shell to zsh..."
    read -p "Do you want to change your default shell to Zsh? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        chsh -s "$(which zsh)"
        success "Default shell changed to Zsh."
    fi
fi

# Step 8: Initialize wallpaper
if ! pgrep -x swww-daemon >/dev/null; then
    info "Starting swww-daemon..."
    swww-daemon &
    sleep 1
fi

WALLPAPER_DIR="assets/wallpapers"
if [[ -d "$WALLPAPER_DIR" ]]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | head -n 1)
    if [[ -n "$WALLPAPER" ]]; then
        info "Setting wallpaper to $WALLPAPER..."
        swww img "$WALLPAPER"
        
        # Step 9: Run matugen on current wallpaper
        if command -v matugen &> /dev/null; then
            info "Running matugen on wallpaper..."
            matugen image "$WALLPAPER" || warn "Matugen failed to generate color scheme."
        else
            warn "matugen not found, skipping color scheme generation."
        fi
    else
        warn "No wallpapers found in $WALLPAPER_DIR."
    fi
fi

# Step 10: Summary
success "Installation and deployment completed!"
info "Please log out and log back into Hyprland for all changes to take effect."
