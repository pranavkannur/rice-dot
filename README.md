# 🌙 rice_dot

A centralized, reproducible Arch Linux dotfiles repository inspired by [Caelestia-dots](https://github.com/caelestia-dots/caelestia) — featuring dynamic Material You theming, dark/light mode, and a fully integrated desktop environment.

## ✨ Features

- **Hyprland Wayland Compositor** — Tiling WM with 144Hz support, smooth animations, and acrylic blur
- **Material You Dynamic Theming** — Wallpaper-driven color palette via `matugen` across all apps
- **Dark / Light Mode Toggle** — One-key (`SUPER + T`) instant system-wide theme switch
- **Interactive Settings Menu** — Visual wallpaper picker, opacity/blur/animation sliders, VPN/DNS controls (`SUPER + S`)
- **App Theme Sync** — Spotify (spicetify), VS Code, Discord (vencord), Kitty, Waybar all match your palette
- **AI Mic Noise Suppression** — EasyEffects + RNNoise removes fan noise and keyboard clicks in real time
- **Developer Productivity** — Dropdown terminal, lazygit modal, clipboard history, color picker, project launcher
- **Safe Deployment** — Non-destructive installer with automatic config backups

## 📦 Quick Start

```bash
git clone <your-repo-url> ~/rice_dot
cd ~/rice_dot
./install.sh
```

The installer will:
1. Verify Arch Linux and install `yay` if needed
2. Install all packages from `packages/pacman-packages.txt` and `packages/aur-packages.txt`
3. Backup any existing configs in `~/.config` to `~/.config_backup_<timestamp>/`
4. Deploy all configuration symlinks
5. Set Zsh as default shell
6. Initialize wallpaper and color scheme

## ⌨️ Keybindings

### Core
| Keybinding | Action |
| :--- | :--- |
| `SUPER + Return` | Open Kitty terminal |
| `SUPER + Q` | Close active window |
| `SUPER + Space` | App launcher (Rofi) |
| `SUPER + E` | File manager (Nautilus) |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + L` | Lock screen (Hyprlock) |

### Workspace
| Keybinding | Action |
| :--- | :--- |
| `SUPER + 1-9,0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-9,0` | Move window to workspace |
| `SUPER + H/J/K/L` | Move focus left/down/up/right |
| `SUPER + SHIFT + H/J/K/L` | Move window |

### System & Theming
| Keybinding | Action |
| :--- | :--- |
| `SUPER + T` | Toggle dark/light mode |
| `SUPER + S` | Settings menu (wallpaper, opacity, VPN, DNS) |
| `SUPER + SHIFT + Escape` | Power menu |
| `Print` / `SUPER + SHIFT + S` | Screenshot (area selection) |

### Developer Tools
| Keybinding | Action |
| :--- | :--- |
| `` SUPER + ` `` | Dropdown scratchpad terminal |
| `SUPER + G` | Floating lazygit |
| `SUPER + V` | Clipboard history |
| `SUPER + SHIFT + C` | Color picker → clipboard |
| `SUPER + M` | Floating btop monitor |
| `SUPER + P` | Project launcher |

### Audio & Media
| Keybinding | Action |
| :--- | :--- |
| `XF86AudioMute` | Toggle speaker mute |
| `XF86AudioMicMute` / `SUPER + ALT + M` | Toggle mic mute |
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume ±5% |
| `SUPER + SHIFT + Up/Down` | Mic gain adjustment |
| `XF86AudioPlay/Prev/Next` | Media controls |
| `XF86MonBrightnessUp/Down` | Brightness ±5% |

## 📁 Repository Structure

```
rice_dot/
├── install.sh                    # Master installer (one command setup)
├── packages/
│   ├── pacman-packages.txt       # Official Arch packages
│   └── aur-packages.txt          # AUR packages
├── configs/
│   ├── hypr/                     # Hyprland compositor
│   ├── waybar/                   # Status bar (Material You pills)
│   ├── rofi/                     # App launcher & power menu
│   ├── swaync/                   # Notification center
│   ├── kitty/                    # Terminal emulator
│   ├── matugen/                  # Dynamic color generation
│   ├── easyeffects/              # Audio DSP (noise suppression)
│   ├── fastfetch/                # System info
│   ├── nvim/                     # Neovim (TODO)
│   ├── zsh/.zshrc                # Shell configuration
│   ├── starship.toml             # Prompt theme
│   └── gtk-3.0/ & gtk-4.0/      # GTK theme settings
├── scripts/
│   ├── deploy.sh                 # Safe symlink deployment with backups
│   ├── theme-toggle.sh           # Dark/light mode switcher
│   ├── settings-menu.sh          # Interactive settings GUI
│   ├── wallpaper.sh              # Wallpaper manager + color refresh
│   ├── screenshot.sh             # Screenshot utility
│   └── powermenu.sh              # Session power menu
└── assets/
    └── wallpapers/               # Curated wallpapers
```

## 🎨 Theming

Colors are dynamically generated from your wallpaper using **matugen** (Material You). Change your wallpaper and every app updates automatically:

- **Kitty** — Live color reload
- **Waybar & SwayNC** — CSS variable injection
- **Rofi** — Color token replacement
- **Hyprland** — Border/accent updates
- **Spotify** — spicetify dynamic theme
- **VS Code** — workbench.colorCustomizations
- **Discord** — Vencord dynamic CSS
- **GTK 3 & 4** — gsettings dark/light + css overrides

## 🖥️ Hardware

Built and tested on:
- **ASUS ROG Strix G713IC** — AMD Ryzen 7 4800H + NVIDIA RTX 3050 Mobile
- **Display** — 17.3" 1920x1080 @ 144Hz (eDP-1)
- **Audio** — PipeWire 1.6.8 + WirePlumber

## 📋 Dependencies

All dependencies are automatically installed by `install.sh`. See:
- [`packages/pacman-packages.txt`](packages/pacman-packages.txt) — Official repository packages
- [`packages/aur-packages.txt`](packages/aur-packages.txt) — AUR packages

## 🔧 Manual Adjustments

- **Monitor config**: Edit `configs/hypr/monitors.conf` for your display setup
- **Visual tweaks**: Use `SUPER + S` settings menu or edit `configs/hypr/hypr-vars.conf`
- **VPN**: Configure VPN connections in NetworkManager first, then manage via settings menu

## 📜 License

MIT
