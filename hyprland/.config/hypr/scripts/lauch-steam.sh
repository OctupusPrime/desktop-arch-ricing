#!/bin/bash

active_class=$(hyprctl activewindow | grep "class: " | cut -d' ' -f2)

if [[ "$active_class" == "steam" ]]; then
  hyprctl dispatch togglespecialworkspace steam
else
  steam
fi
