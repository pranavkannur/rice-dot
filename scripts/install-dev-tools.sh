#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# DEVELOPER ENVIRONMENT & APP SUITE INSTALLER (rice_dot)
# ==============================================================================
# Installs:
# - Docker & Docker Compose
# - Visual Studio Code (visual-studio-code-bin)
# - MySQL / MariaDB (mariadb)
# - MongoDB (mongodb-bin)
# - Node.js & npm
# - Python & pip
# - Postman GUI (postman-bin)
# - Git
# - Antigravity & Antigravity CLI (agy)
# - Ollama (local LLM runtime)
# - VLC Media Player
# - Vesktop (Discord with Vencord)
# - Spotify
# ==============================================================================

info() { echo -e "\e[34m[INFO]\e[0m $1"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
warn() { echo -e "\e[33m[WARN]\e[0m $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m $1"; exit 1; }

echo "=========================================================="
echo "      🚀 Full Developer & Application Suite Setup        "
echo "=========================================================="

# 1. Verify Pacman & Arch Linux
if ! command -v pacman &>/dev/null; then
    error "pacman not found. This script requires Arch Linux."
fi

# 2. Check / Install yay for AUR
if ! command -v yay &>/dev/null; then
    info "yay AUR helper not found. Installing yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bin
    success "yay installed successfully."
fi

# 3. Official Pacman Packages
PACMAN_PACKAGES=(
    git
    docker
    docker-compose
    mariadb
    nodejs
    npm
    python
    python-pip
    ollama
    vlc
    spotify-launcher
)

info "Installing official packages via pacman..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
success "Official packages installed."

# 4. AUR Packages
AUR_PACKAGES=(
    visual-studio-code-bin
    mongodb-bin
    postman-bin
    vesktop-bin
    spotify
    antigravity
    antigravity-cli
)

info "Installing AUR packages via yay..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
success "AUR packages installed."

# 5. Service & Post-Install Configuration

# --- Docker Configuration ---
info "Configuring Docker service & permissions..."
sudo systemctl enable --now docker.service || warn "Could not enable docker.service"
if ! groups "$USER" | grep -q '\bdocker\b'; then
    info "Adding $USER to docker group (run without sudo)..."
    sudo usermod -aG docker "$USER"
    success "Added $USER to docker group. (Will take full effect after re-login)"
fi

# --- MariaDB / MySQL Configuration ---
info "Configuring MariaDB (MySQL)..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
    info "Initializing MariaDB data directory..."
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi
sudo systemctl enable --now mariadb.service || warn "Could not enable mariadb.service"
success "MariaDB initialized and service enabled."

# --- MongoDB Configuration ---
info "Enabling MongoDB service..."
sudo systemctl enable --now mongodb.service || warn "Could not enable mongodb.service"

# --- Ollama Configuration ---
info "Enabling Ollama service..."
sudo systemctl enable --now ollama.service || warn "Could not enable ollama.service"

echo ""
echo "=========================================================="
success "All developer tools and applications are installed!"
echo "=========================================================="
echo "Installed Suite:"
echo "  • Git: $(git --version)"
echo "  • Node.js: $(node --version 2>/dev/null || echo 'Installed') / npm: $(npm --version 2>/dev/null || echo 'Installed')"
echo "  • Python: $(python --version 2>/dev/null || echo 'Installed')"
echo "  • Docker: $(docker --version 2>/dev/null || echo 'Installed')"
echo "  • MariaDB / MySQL: $(mariadb --version 2>/dev/null || echo 'Installed')"
echo "  • MongoDB: $(mongod --version 2>/dev/null | head -n 1 || echo 'Installed')"
echo "  • Ollama: $(ollama --version 2>/dev/null || echo 'Installed')"
echo "  • VS Code: visual-studio-code-bin"
echo "  • Postman GUI: postman-bin"
echo "  • Antigravity & Antigravity CLI (agy)"
echo "  • VLC Player"
echo "  • Vesktop (Discord)"
echo "  • Spotify"
echo "=========================================================="
info "Note: If this was your first time adding yourself to the docker group, log out and back in for non-sudo docker usage."
