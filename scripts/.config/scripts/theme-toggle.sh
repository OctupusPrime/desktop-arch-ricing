#!/bin/bash

# TODO figure out flatpacks if not just fuck it
# TODO select color theme that have variants for gtk and qt

# --- Usage ---
# ./theme_toggle.sh light
# ./theme_toggle.sh dark

# --- Configuration ---
MODE=$1

# Theme Names
GTK_LIGHT="Catppuccin-Latte-Standard-Blue-Light"
GTK_DARK="Catppuccin-Frappe-Standard-Blue-Dark"

KV_LIGHT="catppuccin-latte-blue"
KV_DARK="catppuccin-frappe-blue"

# --- Validation ---
if [[ "$MODE" != "light" && "$MODE" != "dark" ]]; then
    echo "Error: Argument must be 'light' or 'dark'"
    exit 1
fi

# --- Logic ---

if [ "$MODE" == "light" ]; then
    echo "Switching to Light Mode..."

    # --- GTK (Firefox, etc) ---
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

    # --- Qt / Dolphin ---
    kvantummanager --set "$KV_LIGHT"

elif [ "$MODE" == "dark" ]; then
    echo "Switching to Dark Mode..."

    # --- GTK ---
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

    # --- Qt / Dolphin ---
    kvantummanager --set "$KV_DARK"
    
fi