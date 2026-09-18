# rice_dot — Implementation Plan & Roadmap

## 1. Project Phases & Milestones

### Phase 1: Foundation & Repository Setup
- [ ] Initialize Git repository in `rice_dot` with appropriate `.gitignore`
- [ ] Create repository directory tree (`configs/`, `scripts/`, `packages/`, `assets/wallpapers/`)
- [ ] Build idempotent `install.sh` and `scripts/deploy.sh`:
  - Automatic backup of existing configs to `~/.config_backup_<timestamp>/`
  - Symlink deployment from `configs/<app>` to `~/.config/<app>`
  - Support pure `ln -sfn` shell mode

---

### Phase 2: Core Packages & Font Installation
- [ ] Curate `packages/pacman-packages.txt`:
  - Compositor: `hyprland`, `hyprlock`, `hypridle`, `xdg-desktop-portal-hyprland`
  - Bar & Widgets: `waybar`, `swaync`, `rofi-wayland`
  - Terminal & Shell: `kitty`, `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `starship`
  - CLI Utilities: `fastfetch`, `btop`, `eza`, `bat`, `fzf`, `ripgrep`, `zoxide`, `wl-clipboard`, `lazygit`
  - Media & Graphics: `swww`, `grim`, `slurp`, `swappy`, `pavucontrol`, `brightnessctl`, `playerctl`, `hyprpicker`
  - Audio Processing: `easyeffects`
  - Fonts: `ttf-jetbrains-mono-nerd`, `ttf-font-awesome`, `noto-fonts-emoji`
  - Editor: `neovim`
- [ ] Curate `packages/aur-packages.txt`:
  - `matugen-bin` (Material You color generator)
  - `spicetify-cli` (Spotify theming)
  - `bibata-cursor-theme-bin` (cursor theme)
  - `cliphist` (clipboard history manager)
- [ ] Verify `yay` AUR helper and install all packages

---

### Phase 3: Shell & Terminal Rice
- [ ] Configure Zsh as primary shell with Starship prompt
- [ ] Set up Starship prompt (`starship.toml`) with minimal Nerd Font glyphs and git status
- [ ] Configure Kitty terminal:
  - JetBrains Mono Nerd Font @ 9.5pt–10pt
  - Background opacity: `0.92` with blur
  - Dynamic color palette from `matugen` templates
- [ ] Configure shell aliases and integrations in `.zshrc`:
  - `ls` → `eza --icons`, `cat` → `bat`, `grep` → `rg`
  - `zoxide`, `fzf` keybindings (`Ctrl+T`, `Ctrl+R`, `Alt+C`), `starship` init

---

### Phase 4: Compositor & Desktop Environment
- [ ] Configure Hyprland compositor core (`hyprland.conf`):
  - Display: `monitor=eDP-1,1920x1080@144,0x0,1`
  - Dual GPU Wayland env variables (`XDG_SESSION_TYPE`, `GDK_BACKEND`, `QT_QPA_PLATFORM`, etc.)
  - Aesthetics: 10px rounded corners, 1px active border, 4–6px gaps, acrylic blur
  - Full keybinding suite (window management, workspaces, media keys)
- [ ] Configure Waybar status bar (Material You slim pills, compact modules)
- [ ] Configure Rofi-Wayland (app launcher & power menu)
- [ ] Configure SwayNotificationCenter (notification daemon & control center)
- [ ] Setup screen locking & idle management (`hyprlock`, `hypridle`)
- [ ] Setup wallpaper daemon (`swww`) with smooth transitions
- [ ] Configure audio & microphone keybindings with visual OSD:
  - Mic Mute: `XF86AudioMicMute` & `SUPER + Alt + M` with Red/Green pill OSD
  - Speaker Mute: `XF86AudioMute`
  - Volume Up/Down: `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` (5% steps)
  - Mic Gain: `SUPER + Shift + Up/Down`
- [ ] Install & configure audio control suite:
  - `pavucontrol` (per-app volume and input/output device control)
  - `easyeffects` with RNNoise AI noise suppression preset
- [ ] Configure Network, VPN & DNS controls in settings menu and control center

---

### Phase 5: Dynamic Theming, Dark/Light Mode & App Sync
- [ ] Implement `matugen` dynamic color extraction from wallpaper
- [ ] Implement Dark/Light mode one-key toggle (`SUPER + T`) via `scripts/theme-toggle.sh`:
  - Re-runs `matugen image <wallpaper> -m dark/light`
  - Updates GTK dark/light via `gsettings`
  - Reloads Kitty colors, Waybar CSS, SwayNC styles, Hyprland borders
- [ ] Configure `matugen` template outputs for:
  - Kitty color palette (`configs/kitty/colors.conf`)
  - Waybar CSS variables
  - SwayNC CSS variables
  - Rofi color definitions
  - GTK 3 & GTK 4 overrides
  - Hyprland border/accent colors
- [ ] Configure application theme synchronization:
  - **Spotify**: `spicetify-cli` with dynamic Material You template
  - **VS Code**: `workbench.colorCustomizations` in `settings.json`
  - **Discord (Vesktop/Vencord)**: Dynamic CSS theme injection
- [ ] Curate paired dark & light wallpapers in `assets/wallpapers/`

---

### Phase 6: Interactive Settings & Customization Menu
- [ ] Build `scripts/settings-menu.sh` (accessible via `SUPER + S`):
  - Visual wallpaper picker with thumbnail grid
  - Live window & panel opacity sliders (via `hyprctl keyword`)
  - Blur intensity adjustment
  - Animation speed presets (Fast / Balanced / Smooth / Off)
  - Glassmorphism & window shadow toggles
  - VPN quick connect/disconnect (WireGuard, OpenVPN, Tailscale, NetworkManager)
  - DNS profile switcher (Cloudflare, AdGuard, Quad9, Google, Auto DHCP)
  - Dark/Light mode toggle
  - Automatic persistence to `~/.config/hypr/hypr-vars.conf`

---

### Phase 7: Developer Experience & Productivity
- [ ] Dropdown scratchpad terminal (`SUPER + \`` — Quake-style slide-down Kitty)
- [ ] Floating lazygit modal (`SUPER + G`)
- [ ] Smart project launcher (`SUPER + P`) — fuzzy-search projects, opens in VSCode/Neovim
- [ ] Clipboard history manager (`SUPER + V`) — cliphist + Rofi
- [ ] Color picker (`SUPER + Shift + C`) — hyprpicker, copies HEX to clipboard
- [ ] Performance monitor (`SUPER + M`) — floating themed btop
- [ ] Workspace auto-routing rules:
  - WS 1: Code editors, WS 2: Browser, WS 3: Terminals, WS 4: Tools, WS 5: Comms, WS 6: Media

---

### Phase 8: Neovim & Editor Configuration
- [ ] Neovim configuration with `lazy.nvim`:
  - Treesitter syntax highlighting
  - LSP via `mason.nvim` + `nvim-lspconfig` (Python, TypeScript, Rust, Go, C/C++, Lua, Bash)
  - Completion: `nvim-cmp` or `blink.cmp`
  - Fuzzy finder: `telescope.nvim` or `fzf-lua`
  - Format-on-save: `conform.nvim` (prettier, black, stylua, shfmt)
  - Statusline: `lualine.nvim` with dynamic theme
  - Git integration: `gitsigns.nvim` for in-line blame and change signs
- [ ] Git global configuration (`.gitconfig`)
- [ ] VS Code / VSCodium workspace settings & keybindings sync

---

### Phase 9: Automation, Validation & Documentation
- [ ] Validate all shell scripts (`bash -n install.sh`, `bash -n scripts/*.sh`)
- [ ] Validate JSON, TOML, and CSS config syntax
- [ ] Test `scripts/deploy.sh` idempotency (run twice, no errors, no data loss)
- [ ] Verify backup mechanism creates timestamped archives correctly
- [ ] Complete `README.md` with:
  - Visual preview screenshots
  - Full keybinding cheat sheet
  - Setup guide (one-command `install.sh`)
  - Troubleshooting guide for Wayland & hybrid graphics

---

## 2. Core Architectural Decisions

| Decision Area | Selected Option | Notes |
| :--- | :--- | :--- |
| **Aesthetic / Inspiration** | Caelestia-dots (Minimal) | Material You, small 12–14px icons, 9.5pt typography, slim 28–32px pills |
| **Compositor / WM** | Hyprland | Wayland, 144Hz eDP-1, AMD iGPU primary + NVIDIA prime offload |
| **Shell / Bar Engine** | Waybar (Material You CSS) OR Caelestia Shell | Pending: Native Quickshell vs pure CSS Waybar |
| **Terminal** | Kitty | Acrylic blur, live color reload, JetBrains Mono Nerd Font 9.5pt |
| **Shell & Prompt** | Zsh + Starship | Confirmed: autosuggestions + syntax-highlighting |
| **Dynamic Theming** | Matugen (Material You) | Wallpaper-driven palette, dark/light mode, template outputs |
| **App Sync** | Spotify + VS Code + Discord | spicetify, colorCustomizations, vencord CSS |
| **Audio** | PipeWire + EasyEffects + pavucontrol | RNNoise AI noise suppression, mic mute OSD |
| **Network** | VPN + DNS controls in Settings | WireGuard/Tailscale, Cloudflare/AdGuard DNS |
| **Dotfile Linking** | Custom idempotent `install.sh` | Non-destructive symlinker with auto-backup |

---

## 3. Immediate Next Steps
1. Select bar/shell approach: Native Caelestia Quickshell vs Pure Waybar Material You CSS.
2. Initialize Git repository and create directory scaffolding (Phase 1).
3. Install core packages and Nerd Fonts (Phase 2).
