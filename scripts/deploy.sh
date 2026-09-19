#!/usr/bin/env bash

set -e

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DRY_RUN=0

if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=1
    echo "[INFO] Running in dry-run mode"
fi

CONFIG_MAP=(
    "hypr:$HOME/.config/hypr"
    "waybar:$HOME/.config/waybar"
    "rofi:$HOME/.config/rofi"
    "swaync:$HOME/.config/swaync"
    "kitty:$HOME/.config/kitty"
    "matugen:$HOME/.config/matugen"
    "easyeffects:$HOME/.config/easyeffects"
    "fastfetch:$HOME/.config/fastfetch"
    "nvim:$HOME/.config/nvim"
    "gtk-3.0:$HOME/.config/gtk-3.0"
    "gtk-4.0:$HOME/.config/gtk-4.0"
    "starship.toml:$HOME/.config/starship.toml"
    "zsh/.zshrc:$HOME/.zshrc"
    "git/.gitconfig:$HOME/.gitconfig"
)

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_CREATED=0

for MAP in "${CONFIG_MAP[@]}"; do
    SRC_REL="${MAP%%:*}"
    TARGET="${MAP##*:}"
    
    SRC_ABS="$DOTFILES_DIR/configs/$SRC_REL"
    
    # Check if target is already a symlink pointing to SRC_ABS
    if [[ -L "$TARGET" && "$(readlink -f "$TARGET")" == "$SRC_ABS" ]]; then
        echo -e "\e[34m[SKIP]\e[0m $TARGET is already linked"
        continue
    fi
    
    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo -e "\e[33m[BACKUP]\e[0m (dry-run) Would back up $TARGET to $BACKUP_DIR"
        else
            if [[ $BACKUP_CREATED -eq 0 ]]; then
                mkdir -p "$BACKUP_DIR"
                BACKUP_CREATED=1
            fi
            mv "$TARGET" "$BACKUP_DIR/"
            echo -e "\e[33m[BACKUP]\e[0m Backed up $TARGET to $BACKUP_DIR"
        fi
    fi
    
    if [[ $DRY_RUN -eq 1 ]]; then
        echo -e "\e[32m[LINK]\e[0m (dry-run) Would link $SRC_ABS -> $TARGET"
    else
        mkdir -p "$(dirname "$TARGET")"
        ln -sfn "$SRC_ABS" "$TARGET"
        echo -e "\e[32m[LINK]\e[0m Linked $SRC_ABS -> $TARGET"
    fi
done

# Link user scripts into ~/.local/bin
if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/scripts"/*.sh; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
            sname=$(basename "$script")
            base="${sname%.sh}"
            ln -sfn "$script" "$HOME/.local/bin/$sname"
            ln -sfn "$script" "$HOME/.local/bin/$base"
        fi
    done
    # Alias compatibility symlinks
    ln -sfn "$DOTFILES_DIR/scripts/powermenu.sh" "$HOME/.local/bin/power-menu.sh"
    
    # Ensure swww aliases to awww if awww is installed
    if command -v awww &>/dev/null && ! command -v swww &>/dev/null; then
        ln -sfn "$(which awww)" "$HOME/.local/bin/swww"
        ln -sfn "$(which awww-daemon)" "$HOME/.local/bin/swww-daemon"
    fi
fi

