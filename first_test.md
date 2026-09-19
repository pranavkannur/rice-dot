# rice_dot — System Audit & Troubleshooting Report

**Date:** 2026-09-18 / 2026-09-19  
**Target Environment:** Arch Linux (Kernel `7.2.6-arch2-1`), Hyprland v0.56.2, Wayland  
**Repository Path:** `/home/g17/rice_dot`  
**Evaluation Target:** [`plan.md`](file:///home/g17/rice_dot/plan.md) vs. Current Deployed State  
**Audit Status:** Initial Top Bar Errors Resolved | Additional Functional Gaps & Configuration Issues Diagnosed  

---

## 1. Executive Summary

This report documents the findings of two testing and audit phases on the `rice_dot` environment:
1. **Initial Compositor Startup:** Diagnosis and resolution of the 18 configuration parsing errors that rendered a persistent red warning banner across the top of Hyprland.
2. **Comprehensive Roadmap Audit:** A systematic, phase-by-phase validation of all components defined in [`plan.md`](file:///home/g17/rice_dot/plan.md), checking daemon health, script execution, keybindings, dynamic theming, and package dependencies.

While the primary graphical compositor, status bar (Waybar), notification center (SwayNC), terminal (Kitty), and shell (Zsh + Starship) are running successfully, several critical runtime mismatches, missing scripts, and unlinked paths were discovered that prevent keybindings and theming workflows from executing as planned.

---

## 2. Phase-by-Phase Roadmap Audit (`plan.md`)

| Phase | Milestone Name | Status | Summary of Audit Findings |
| :--- | :--- | :---: | :--- |
| **Phase 1** | Foundation & Repository Setup | **Partially Working** | Git repository and directory tree established. Symlink deployment via `deploy.sh` works for `~/.config`, but does **not** link user scripts in `scripts/` into `~/.local/bin`. |
| **Phase 2** | Core Packages & Fonts | **Working (with notes)** | 48/48 Pacman packages and 6/6 AUR packages verified installed. Note: `awww` is installed instead of upstream `swww`; `papirus-icon-theme` is missing. |
| **Phase 3** | Shell & Terminal Rice | **Working** | Zsh is active shell (`/usr/bin/zsh`); Starship, Zoxide, FZF, and Kitty are fully functional. Static Kitty colors work, but live color regeneration is blocked. |
| **Phase 4** | Compositor & Desktop Env | **Fixed / Working** | Hyprland 0.56.2 errors resolved; Waybar and SwayNC run cleanly; `hypridle` and `hyprlock` active. `swww-daemon` autostart fails due to missing PATH. |
| **Phase 5** | Dynamic Theming & Matugen | **Blocked / Broken** | `matugen` 4.2+ hangs waiting for interactive stdin; all Jinja template files (`.j2`) are missing; `assets/wallpapers/` contains no wallpapers; app sync (Spotify, Discord, VS Code) unconfigured. |
| **Phase 6** | Interactive Settings Menu | **Partially Working** | `settings-menu.sh` runs and modifies variables, but `$anim_speed` is completely ignored by `hyprland.conf`; shadow and glassmorphism toggles are not yet implemented. |
| **Phase 7** | Dev Experience & Productivity | **Partially Working** | `lazygit` (`SUPER+G`), `btop` (`SUPER+M`), `cliphist` (`SUPER+V`), `hyprpicker` (`SUPER+Shift+C`) work. `project-launcher.sh` (`SUPER+P`) is missing; scratchpad terminal lacks dropdown/float rules. |
| **Phase 8** | Neovim & Editor Configuration | **Not Started** | `configs/nvim` contains only `.keep`. `lazy.nvim`, LSP configs, treesitter, and plugins are completely unconfigured. |
| **Phase 9** | Automation & Validation | **Partially Working** | Shell scripts pass `bash -n`. Idempotency of `install.sh` has minor path gaps. |

---

## 3. Initial Top-Bar Errors & Fixes (Resolved)

When Hyprland initially launched, 18 configuration errors generated a red banner across the top of the screen.

### Issue 3.1: Deprecated Shadow Syntax in `decoration`
- **Errors Reported:**
  ```text
  Config error in file ... at line 81: config option <decoration:drop_shadow> does not exist.
  Config error in file ... at line 82: config option <decoration:shadow_range> does not exist.
  Config error in file ... at line 83: config option <decoration:shadow_render_power> does not exist.
  Config error in file ... at line 84: config option <decoration:col.shadow> does not exist.
  ```
- **Root Cause:** Hyprland moved shadow properties into a dedicated `shadow { ... }` sub-block and renamed `col.shadow` to `color`.
- **Solution Applied in `configs/hypr/hyprland.conf`:**
  ```hyprland
  decoration {
      ...
      shadow {
          enabled = $shadow_enabled
          range = $shadow_range
          render_power = $shadow_render_power
          color = rgba(1a1a1aee)
      }
  }
  ```

### Issue 3.2: Removed `pseudotile` in `dwindle`
- **Error Reported:**
  ```text
  Config error in file ... at line 107: config option <dwindle:pseudotile> does not exist.
  ```
- **Root Cause:** The global `pseudotile` toggle in the `dwindle` block was deprecated. Pseudotiling is handled dynamically via dispatchers.
- **Solution Applied:** Removed `pseudotile = true` from the `dwindle` block.

### Issue 3.3: Deprecated `windowrulev2` and Strict Typing
- **Errors Reported:**
  ```text
  Config error in file ...: windowrulev2 is deprecated. Correct syntax can be found on the wiki.
  invalid field float: missing a value
  invalid field class:...: missing a value
  invalid field center: missing a value
  ```
- **Root Cause:** Hyprland v0.53+ unified rules under `windowrule`, required the `match:` prefix for selectors (`match:class`, `match:title`), and required explicit values for boolean directives (`float 1`, `center 1`).
- **Solution Applied:** All 13 rule lines were migrated to the unified format:
  ```hyprland
  windowrule = float 1, match:class ^(pavucontrol)$
  windowrule = float 1, match:class ^(nm-connection-editor)$
  windowrule = float 1, match:class ^(file-roller)$
  windowrule = float 1, match:class ^(polkit-gnome-authentication-agent-1)$
  windowrule = float 1, match:title ^(File Operation)$
  windowrule = opacity $active_opacity $inactive_opacity, match:class ^(kitty)$
  windowrule = float 1, match:class ^(float-.*)$
  windowrule = size 80% 80%, match:class ^(float-.*)$
  windowrule = center 1, match:class ^(float-.*)$
  windowrule = workspace special:scratchpad, match:class ^(scratchpad)$
  windowrule = workspace 5, match:class ^(vesktop)$
  windowrule = workspace 5, match:class ^(discord)$
  windowrule = workspace 6, match:class ^(Spotify)$
  ```

---

## 4. Newly Diagnosed Issues & Broken Features

During the full system plan audit, the following new issues and behavioral discrepancies were diagnosed:

### Issue 4.1: Missing User PATH in Hyprland Environment (High Severity)
- **Symptom:** Wallpaper daemon fails to autostart (`swww-daemon`), and custom keybindings calling helper scripts fail with `command not found`.
- **Diagnosis:** Hyprland is launched by SDDM with a minimal system PATH:
  ```text
  PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
  ```
  Neither `/home/g17/.local/bin` (where `swww-daemon` symlink lives) nor `/home/g17/rice_dot/scripts` are included in Hyprland's execution environment.
- **Remediation:** Add the user PATH explicitly to the environment section in [`configs/hypr/hyprland.conf`](file:///home/g17/rice_dot/configs/hypr/hyprland.conf):
  ```hyprland
  env = PATH,$HOME/.local/bin:$HOME/rice_dot/scripts:$PATH
  ```

---

### Issue 4.2: Missing Project Launcher Script (High Severity)
- **Symptom:** Pressing `SUPER + P` produces no action.
- **Diagnosis:** [`configs/hypr/hyprland.conf`](file:///home/g17/rice_dot/configs/hypr/hyprland.conf) line 161 binds `SUPER + P` to `exec, project-launcher.sh`. However, no file named `project-launcher.sh` exists anywhere in `rice_dot/scripts/` or the system.
- **Remediation:** Create `scripts/project-launcher.sh` utilizing `fzf`/`rofi` to search directories (e.g. `~/Projects` or `~/rice_dot`) and open the selected target in `$EDITOR` or `code`.

---

### Issue 4.3: Power Menu Keybinding Script Name Mismatch (Medium Severity)
- **Symptom:** Pressing `SUPER + Shift + Escape` fails to launch the power menu.
- **Diagnosis:** Line 159 of `hyprland.conf` specifies `exec, power-menu.sh` (with hyphen), whereas the repository script is named [`scripts/powermenu.sh`](file:///home/g17/rice_dot/scripts/powermenu.sh) (without hyphen).
- **Remediation:** Update `hyprland.conf` line 159 to `exec, powermenu.sh` (or create a symlink `power-menu.sh -> powermenu.sh`).

---

### Issue 4.4: Matugen 4.2+ Interactive Prompt Freeze (High Severity)
- **Symptom:** Pressing `SUPER + T` (theme toggle) or running `wallpaper.sh` causes the script to hang indefinitely.
- **Diagnosis:** In Matugen v4.2+, running `matugen image <file> -m <mode>` without specifying `--source-color-index` triggers an interactive TUI prompt:
  ```text
  Select the color you want to use as source color
  Use arrow keys to navigate and Enter to select:
  > #4285f4
  ```
  Because scripts run non-interactively in background processes, they stall forever waiting for terminal input.
- **Remediation:** Update calls in [`scripts/theme-toggle.sh`](file:///home/g17/rice_dot/scripts/theme-toggle.sh), [`scripts/wallpaper.sh`](file:///home/g17/rice_dot/scripts/wallpaper.sh), and [`install.sh`](file:///home/g17/rice_dot/install.sh) to include:
  ```bash
  matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0
  ```

---

### Issue 4.5: Missing Matugen Template Files (High Severity)
- **Symptom:** When `matugen` does execute, it terminates with an error:
  ```text
  ⚠ The gtk4 template in ~/.config/matugen/templates/gtk.j2 doesn't exist, skipping...
  ⚠ The swaync template in ~/.config/matugen/templates/swaync.j2 doesn't exist, skipping...
  ⚠ The hyprland template in ~/.config/matugen/templates/hyprland.j2 doesn't exist, skipping...
  ⚠ The waybar template in ~/.config/matugen/templates/waybar.j2 doesn't exist, skipping...
  ⚠ The gtk3 template in ~/.config/matugen/templates/gtk.j2 doesn't exist, skipping...
  ⚠ The rofi template in ~/.config/matugen/templates/rofi.j2 doesn't exist, skipping...
  ⚠ The kitty template in ~/.config/matugen/templates/kitty.j2 doesn't exist, skipping...
  Error: Failed to get the input and output paths from hashmap
  ```
- **Diagnosis:** [`configs/matugen/config.toml`](file:///home/g17/rice_dot/configs/matugen/config.toml) defines input paths to Jinja2 templates under `~/.config/matugen/templates/`, but no template files were authored or placed in the repository.
- **Remediation:** Provide standard Material You `.j2` templates for Kitty, Waybar, SwayNC, Rofi, and Hyprland, and ensure `configs/waybar/style.css` and `configs/swaync/style.css` import the generated CSS palettes.

---

### Issue 4.6: Disconnected `$anim_speed` Variable (Medium Severity)
- **Symptom:** Adjusting Animation Speed in `settings-menu.sh` (SUPER + S -> Option 5) has no effect on desktop speed.
- **Diagnosis:** `settings-menu.sh` writes `$anim_speed` to `hypr-vars.conf`, but the `animations` block in [`configs/hypr/hyprland.conf`](file:///home/g17/rice_dot/configs/hypr/hyprland.conf) hardcodes its animation durations (`windows, 1, 5`, `fade, 1, 5`, etc.) and never consumes `$anim_speed`.
- **Remediation:** Use `$anim_speed` in `hyprland.conf` animation durations or adjust animation speed via `hyprctl keyword animations:enabled` and speed multipliers.

---

### Issue 4.7: Empty Wallpaper Repository (Medium Severity)
- **Symptom:** `settings-menu.sh` (Option 1) opens an empty wallpaper picker, and wallpaper autostart fails to find an image.
- **Diagnosis:** Directory `assets/wallpapers/` is completely empty (only `.keep` exists).
- **Remediation:** Curate 2–4 default dark and light wallpapers in `assets/wallpapers/` (e.g. symlinking/copying high-resolution wallpapers or defaults from `/usr/share/backgrounds/`).

---

### Issue 4.8: Dropdown Scratchpad Lacks Floating Behavior (Low Severity)
- **Symptom:** Pressing `SUPER + grave` summons the scratchpad terminal, but it tiles across the screen rather than appearing as a dropdown or floating window.
- **Diagnosis:** Hyprland window rule for `special:scratchpad` specifies `workspace special:scratchpad, match:class ^(scratchpad)$`, but lacks `float 1` and `size`/`center` attributes.
- **Remediation:** Add floating rules for `scratchpad`:
  ```hyprland
  windowrule = float 1, match:class ^(scratchpad)$
  windowrule = size 75% 55%, match:class ^(scratchpad)$
  windowrule = move 12.5% 40, match:class ^(scratchpad)$
  ```

---

### Issue 4.9: Missing Audio / Mic Mute Visual OSD (Low Severity)
- **Symptom:** Toggling mute via `SUPER + Alt + M` or `XF86AudioMicMute` changes the state silently without visual confirmation.
- **Diagnosis:** `hyprland.conf` executes `wpctl set-mute` directly with no notification hook or SwayNC/Waybar OSD event.
- **Remediation:** Wrap volume and mute keybindings in a small helper script (`scripts/volume-control.sh`) that reads the new state and fires `swaync-client` or `notify-send` with an appropriate icon and status pill.

---

### Issue 4.10: Unimplemented Neovim Configuration (Phase 8)
- **Symptom:** Running `nvim` opens a completely unconfigured vanilla Neovim.
- **Diagnosis:** `configs/nvim` is empty (`.keep` only). The planned `lazy.nvim`, LSP, treesitter, and formatting setup is not yet implemented.
- **Remediation:** Author a modular `lazy.nvim` starter configuration in `configs/nvim/init.lua` and `configs/nvim/lua/plugins/`.

---

## 5. Action Items & Prioritized Fixes

```
Priority 1 (Critical - Immediate Functionality):
  [x] Add `env = PATH,$HOME/.local/bin:$HOME/rice_dot/scripts:$PATH` to configs/hypr/hyprland.conf (Resolved)
  [x] Bind standalone Super key release (`bindr = SUPER, SUPER_L/R`) to toggle Rofi app menu (Resolved)
  [ ] Fix keybinding typo in configs/hypr/hyprland.conf: power-menu.sh -> powermenu.sh
  [ ] Create scripts/project-launcher.sh for SUPER + P
  [ ] Add `--source-color-index 0` to all matugen CLI calls in scripts/

Priority 2 (High - Aesthetic & Polish):
  [ ] Create missing Jinja templates in configs/matugen/templates/
  [ ] Wire generated colors into waybar/style.css, swaync/style.css, and rofi/config.rasi
  [ ] Populate assets/wallpapers/ with default wallpapers
  [ ] Connect $anim_speed into hyprland.conf animations block
  [ ] Add float and size rules for scratchpad terminal

Priority 3 (Medium - Enhancements & Completeness):
  [ ] Implement scripts/volume-control.sh for mic/speaker mute OSD
  [ ] Add RNNoise configuration preset in configs/easyeffects/
  [ ] Build Phase 8 Neovim configuration with lazy.nvim
```
