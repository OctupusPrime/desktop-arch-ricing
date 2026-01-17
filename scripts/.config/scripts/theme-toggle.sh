#!/bin/bash

# --- Usage ---
# ./theme_toggle.sh light
# ./theme_toggle.sh dark

MODE=$1

if [[ "$MODE" != "light" && "$MODE" != "dark" ]]; then
    echo "Error: Argument must be 'light' or 'dark'"
    exit 1
fi

# GTK Theme
GTK_LIGHT="Breeze"
GTK_DARK="Breeze-Dark"

# QT Theme
QT_STYLE="Breeze"
QT_LIGHT="/usr/share/color-schemes/BreezeLight.colors"
QT_DARK="/usr/share/color-schemes/BreezeDark.colors"

# Background image
BACKGROUND_LIGHT="$HOME/Pictures/Wallpapers/Light.png"
BACKGROUND_DARK="$HOME/Pictures/Wallpapers/Dark.png"

# Function to update qt5ct and qt6ct config files
update_qt_config() {
    local SCHEME_PATH="$1"
    
    for CONF in "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"; do
        if [ -f "$CONF" ]; then
            echo "Updating $CONF..."
            # Use | as delimiter for sed because paths contain /
            sed -i "s|^color_scheme_path=.*|color_scheme_path=$SCHEME_PATH|" "$CONF"
            sed -i "s|^custom_palette=.*|custom_palette=true|" "$CONF"
            sed -i "s|^style=.*|style=$QT_STYLE|" "$CONF"
        fi
    done
}

if [ "$MODE" == "light" ]; then
    echo "Switching to Light Mode..."

    # --- GTK ---
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

    # --- QT ---
    update_qt_config "$QT_LIGHT"

    # --- Background ---
    hyprctl hyprpaper wallpaper ','"$BACKGROUND_LIGHT"',cover'

elif [ "$MODE" == "dark" ]; then
    echo "Switching to Dark Mode..."

    # --- GTK ---
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

    # --- QT ---
    update_qt_config "$QT_DARK"

    # --- Background ---
    hyprctl hyprpaper wallpaper ','"$BACKGROUND_DARK"',cover'
fi

echo "Theme switch completed."