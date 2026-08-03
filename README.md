# Desktop Arch Ricing

Personal Hyprland configuration for an existing Arch Linux desktop. It combines a Lua-based Hyprland setup with a Quickshell panel, adaptive light/dark themes, media and monitor controls, a system tray, and workspace-aware application launchers.

## Requirements

This repository assumes Hyprland is already installed and working.

Install the core runtime packages:

```bash
sudo pacman -S --needed \
  stow quickshell hyprpaper hyprsunset xdg-desktop-portal-hyprland \
  wl-clipboard cliphist wofi dolphin kitty \
  pipewire wireplumber playerctl brightnessctl \
  qt5ct qt6ct breeze breeze-gtk qt6-positioning geoclue
```

Optional integrations:

- `ddcutil` for external-monitor brightness control
- Codex for the AI terminal button
- Spotify, Steam, and Zen Browser for the dedicated launchers and workspaces
- OpenRazer and Polychromatic for the generated keyboard lighting effect

## Install

```bash
git clone https://github.com/OctupusPrime/desktop-arch-ricing.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
stow quickshell hyprland scripts
```

Only the runtime packages are stowed. The `tools/` directory stays in the repository and is never linked into `~/.config`.

Before restarting Hyprland, review these machine-specific settings:

- Change the `DP-4` monitor name and `1920x1080@165` mode in `hyprland/.config/hypr/hyprland.lua`.
- Add `light.png` and `dark.png` to `~/Pictures/Wallpapers/`, then create the initial wallpaper link:

```bash
ln -sfn "$HOME/Pictures/Wallpapers/dark.png" \
  "$HOME/Pictures/Wallpapers/current_wallpaper"
```

- Adjust the Kitty, Dolphin, Wofi, Codex, Spotify, Steam, and Zen Browser commands if your preferred applications differ.

Restart Hyprland or log in again to load the configuration.

## Repository layout

```text
hyprland/   Hyprland, Hyprpaper, autostart, rules, and keybindings
quickshell/ Quickshell panel, components, services, fonts, and assets
scripts/    Runtime helpers and generated lookup binaries
tools/      Development-only generators and source code
```

## Tools

The generated files are committed with the runtime configuration, so Node.js, Bun, Go, and Python are only needed when changing or rebuilding the tools.

### Fantasticon

Converts SVG files from `quickshell/.config/quickshell/assets/icons/` into `Icons.ttf` and regenerates the matching key/value properties in `common/Icons.qml`.

```bash
npm run build:icons
```

### Solar lookup

Calculates local sunrise and sunset from a date, coordinates, and timezone. Quickshell uses the generated `scripts/.config/scripts/solar-lookup` binary for adaptive theme switching.

```bash
npm run build:solar-lookup
```

### Timezone lookup

Resolves latitude and longitude to an IANA timezone. Quickshell uses the generated `scripts/.config/scripts/tz-lookup` binary to keep the system timezone and solar calculation in sync.

```bash
npm run build:tz-lookup
```

### Polychromatic wave

Generates a custom wave effect for a Razer Huntsman Tournament Edition at `~/.config/polychromatic/effects/Wave.json`.

```bash
python tools/generate-polychromatic-wave.py
```

Install all tool dependencies and rebuild the Go binaries and icon assets from the repository root:

```bash
npm run install
npm run build
```
