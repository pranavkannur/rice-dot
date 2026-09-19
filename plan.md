# rice_dot — Implementation Plan & Roadmap

## 1. Project Phases & Milestones

### Phase 1: Foundation & Repository Setup
- [x] Initialize Git repository in `rice_dot` with appropriate `.gitignore`
- [x] Create repository directory tree (`configs/`, `scripts/`, `packages/`, `assets/wallpapers/`)
- [x] Build idempotent `install.sh` and `scripts/deploy.sh`:
  - Automatic backup of existing configs to `~/.config_backup_<timestamp>/`
  - Symlink deployment from `configs/<app>` to `~/.config/<app>`
  - Automatic user script linking into `~/.local/bin`
  - Pure shell symlink mode with `--dry-run`

---

### Phase 2: Core Packages & Font Installation
- [x] Curate `packages/pacman-packages.txt`:
  - Compositor: `hyprland`, `hyprlock`, `hypridle`, `xdg-desktop-portal-hyprland`
  - Bar & Widgets: `waybar`, `swaync`, `rofi-wayland`
  - Terminal & Shell: `kitty`, `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `starship`
  - CLI Utilities: `fastfetch`, `btop`, `eza`, `bat`, `fzf`, `ripgrep`, `zoxide`, `wl-clipboard`, `lazygit`
  - Media & Graphics: `awww` (replaces `swww`), `grim`, `slurp`, `swappy`, `pavucontrol`, `brightnessctl`, `playerctl`, `hyprpicker`
  - Audio Processing: `easyeffects`
  - Fonts: `ttf-jetbrains-mono-nerd`, `ttf-font-awesome`, `noto-fonts-emoji`
  - Editor: `neovim`
  - Theming: `nwg-look`, `papirus-icon-theme`
- [x] Curate `packages/aur-packages.txt`:
  - `matugen-bin` (Material You color generator)
  - `spicetify-cli` (Spotify theming)
  - `bibata-cursor-theme-bin` (cursor theme)
  - `cliphist` (clipboard history manager)
  - `vesktop-bin` (Discord client with Vencord support)
- [x] Verify `yay` AUR helper and install all packages

---

### Phase 3: Shell & Terminal Rice
- [x] Configure Zsh as primary shell with Starship prompt
- [x] Set up Starship prompt (`starship.toml`) with minimal Nerd Font glyphs and git status
- [x] Configure Kitty terminal:
  - JetBrains Mono Nerd Font @ 10pt
  - Background opacity: `0.92` with acrylic blur
  - Dynamic color palette from `matugen` templates (`colors.conf`)
- [x] Configure shell aliases and integrations in `.zshrc`:
  - `ls` → `eza --icons`, `cat` → `bat`, `grep` → `rg`
  - `zoxide`, `fzf` keybindings, `starship` init

---

### Phase 4: Compositor & Desktop Environment
- [x] Configure Hyprland compositor core (`hyprland.conf`):
  - Display: `monitor=eDP-1,1920x1080@144,0x0,1`
  - Dual GPU Wayland env variables (`XDG_SESSION_TYPE`, `GDK_BACKEND`, `QT_QPA_PLATFORM`, etc.)
  - Aesthetics: 10px rounded corners, 1px active border, 4–8px gaps, acrylic blur, shadows
  - Full keybinding suite (window management, workspaces, media keys)
- [x] Configure Waybar status bar (Material You slim floating pills, compact modules)
- [x] Configure Rofi-Wayland (app launcher & power menu with dynamic `@import "colors.rasi"`)
- [x] Configure SwayNotificationCenter (notification daemon & control center with dynamic `@import "colors.css"`)
- [x] Setup screen locking & idle management (`hyprlock`, `hypridle`)
- [x] Setup wallpaper daemon (`awww` / `swww`) with smooth transitions
- [x] Configure audio & microphone keybindings with visual OSD (`volume-control.sh`):
  - Mic Mute: `XF86AudioMicMute` & `SUPER + Alt + M` with Red/Green pill OSD
  - Speaker Mute: `XF86AudioMute`
  - Volume Up/Down: `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` (5% steps)
  - Mic Gain: `SUPER + Shift + Up/Down`
- [x] Install & configure audio control suite:
  - `pavucontrol` (per-app volume and input/output device control)
  - `easyeffects` with RNNoise AI noise suppression preset
- [x] Configure Network, VPN & DNS controls in settings menu

---

### Phase 5: Dynamic Theming, Dark/Light Mode & App Sync
- [x] Implement `matugen` dynamic color extraction from wallpaper (with non-interactive `--source-color-index 0`)
- [x] Implement Dark/Light mode one-key toggle (`SUPER + T`) via `scripts/theme-toggle.sh`:
  - Re-runs `matugen image <wallpaper> -m dark/light`
  - Updates GTK dark/light via `gsettings`
  - Reloads Kitty colors, Waybar CSS, SwayNC styles, Hyprland borders
  - Synchronizes VS Code theme between Catppuccin Mocha and Catppuccin Latte
- [x] Configure all 6 `matugen` template outputs in `configs/matugen/templates/`:
  - Kitty color palette (`kitty.j2` → `~/.config/kitty/colors.conf`)
  - Waybar CSS variables (`waybar.j2` → `~/.config/waybar/colors.css`)
  - SwayNC CSS variables (`swaync.j2` → `~/.config/swaync/colors.css`)
  - Rofi color definitions (`rofi.j2` → `~/.config/rofi/colors.rasi`)
  - GTK 3 & GTK 4 overrides (`gtk.j2` → `~/.config/gtk-*/gtk.css`)
  - Hyprland border/accent colors (`hyprland.j2` → `~/.config/hypr/colors.conf`)
- [x] Curate paired dark & light wallpapers in `assets/wallpapers/` (`aesthetic.jpg`, `dark-waves.jpg`, `city-horizon.jpg`, `clouds.jpg`)

---

### Phase 6: Interactive Settings & Customization Menu
- [x] Build `scripts/settings-menu.sh` (accessible via `SUPER + S`):
  - Visual wallpaper picker
  - Live window & panel opacity adjustments (via `hyprctl keyword`)
  - Blur intensity adjustment
  - Live animation speed presets (Fast / Balanced / Smooth / Off)
  - Window shadows toggle (Option 6)
  - VPN quick connect/disconnect (NetworkManager)
  - DNS profile switcher (Cloudflare, AdGuard, Quad9, Google, Auto DHCP)
  - Dark/Light mode toggle
  - Automatic persistence to `~/.config/hypr/hypr-vars.conf`

---

### Phase 7: Developer Experience & Productivity
- [x] Dropdown scratchpad terminal (`SUPER + \`` — Quake-style floating slide-down Kitty)
- [x] Floating lazygit modal (`SUPER + G`)
- [x] Smart project launcher (`SUPER + P` via `scripts/project-launcher.sh`)
- [x] Clipboard history manager (`SUPER + V` via `cliphist` + `rofi`)
- [x] Color picker (`SUPER + Shift + C` via `hyprpicker`)
- [x] Performance monitor (`SUPER + M` via `btop`)
- [x] Workspace auto-routing rules (WS 5: Discord/Vesktop, WS 6: Spotify)

---

### Phase 8: Neovim & Editor Configuration
- [x] Neovim configuration with `lazy.nvim` (`configs/nvim/init.lua`):
  - Treesitter syntax highlighting
  - LSP via `mason.nvim` + `mason-lspconfig` + `nvim-lspconfig`
  - Completion: `nvim-cmp` + `LuaSnip`
  - Fuzzy finder: `telescope.nvim`
  - Statusline: `lualine.nvim` with Catppuccin theme
  - File Explorer: `nvim-tree.lua`
  - Git integration: `gitsigns.nvim`
  - Autopairs & Commenting: `nvim-autopairs`, `Comment.nvim`
- [x] Git global configuration (`configs/git/.gitconfig` deployed to `~/.gitconfig`)
- [x] VS Code theme sync hook in `scripts/theme-toggle.sh`

---

### Phase 9: Automation, Validation & Documentation
- [x] Validate all shell scripts (`bash -n install.sh`, `bash -n scripts/*.sh`)
- [x] Validate JSON, TOML, and CSS config syntax
- [x] Test `scripts/deploy.sh` idempotency (tested, all targets report `[SKIP]` or cleanly link)
- [x] Complete `README.md` with:
  - Full keybinding cheat sheet
  - Setup guide (`./install.sh`)
  - Component architecture
  - Hardware profile

---

## 2. Core Architectural Decisions

| Decision Area | Selected Option | Status |
| :--- | :--- | :---: |
| **Aesthetic / Inspiration** | Caelestia-dots (Minimal) | Verified |
| **Compositor / WM** | Hyprland 144Hz | Verified |
| **Shell / Bar Engine** | Waybar Material You Floating Pills | Verified |
| **Terminal** | Kitty (Blur, JetBrains Mono 10pt) | Verified |
| **Shell & Prompt** | Zsh + Starship | Verified |
| **Dynamic Theming** | Matugen (Material You) + 6 Jinja Templates | Verified |
| **App Sync** | VS Code (Catppuccin Mocha/Latte) + Kitty + Waybar + SwayNC | Verified |
| **Audio** | PipeWire + EasyEffects RNNoise + Visual OSD | Verified |
| **Network** | VPN + DNS controls in Settings Menu | Verified |
| **Dotfile Linking** | Idempotent `scripts/deploy.sh` with backups & `~/.local/bin` links | Verified |
