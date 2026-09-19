#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROJECT LAUNCHER (SUPER + P)
# ==============================================================================
# Finds coding projects and opens them in your editor or terminal.

SEARCH_DIRS=(
    "$HOME/Projects"
    "$HOME/rice_dot"
    "$HOME/workspace"
    "$HOME/git"
    "$HOME/Documents"
    "$HOME"
)

# Collect list of project directories (Git repositories or top-level project folders)
PROJECTS=()

for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Check if dir itself has a .git
        if [ -d "$dir/.git" ]; then
            PROJECTS+=("$dir")
        fi
        # Find subdirectories with .git (maxdepth 3)
        while IFS= read -r -d '' gitdir; do
            pdir=$(dirname "$gitdir")
            PROJECTS+=("$pdir")
        done < <(find "$dir" -maxdepth 3 -name ".git" -type d -print0 2>/dev/null)
    fi
done

# Remove duplicates while preserving order
UNIQUE_PROJECTS=($(printf "%s\n" "${PROJECTS[@]}" | sort -u))

if [ ${#UNIQUE_PROJECTS[@]} -eq 0 ]; then
    # Fallback to home and dotfiles
    UNIQUE_PROJECTS=("$HOME/rice_dot" "$HOME")
fi

# Build display list (relative to HOME for clean view)
DISPLAY_LIST=""
for p in "${UNIQUE_PROJECTS[@]}"; do
    DISPLAY_LIST+="${p/#$HOME/~}\n"
done

# Show rofi picker
SELECTED_DISPLAY=$(printf "$DISPLAY_LIST" | rofi -dmenu -i -p "🚀 Open Project")

if [ -z "$SELECTED_DISPLAY" ]; then
    exit 0
fi

# Resolve ~ back to $HOME
SELECTED_PATH="${SELECTED_DISPLAY/#\~/$HOME}"

if [ ! -d "$SELECTED_PATH" ]; then
    notify-send "Project Launcher" "Directory not found: $SELECTED_PATH" -i error
    exit 1
fi

# Action menu for selected project
ACTION=$(printf "1. 💻 Code (VS Code)\n2. ⚡ Neovim (Terminal)\n3. 🖥️ Terminal (Kitty)\n4. 📁 Files (Nautilus)" | rofi -dmenu -i -p "Action")

case "$ACTION" in
    1*|"")
        if command -v code &>/dev/null; then
            code "$SELECTED_PATH"
        else
            kitty --directory "$SELECTED_PATH" nvim .
        fi
        ;;
    2*)
        kitty --directory "$SELECTED_PATH" nvim .
        ;;
    3*)
        kitty --directory "$SELECTED_PATH"
        ;;
    4*)
        nautilus "$SELECTED_PATH"
        ;;
esac
