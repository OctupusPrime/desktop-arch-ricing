#!/bin/bash

active_class=$(hyprctl activewindow | grep "class: " | cut -d' ' -f2)

if [[ "$active_class" == "zen" ]]; then
  hyprctl dispatch togglespecialworkspace browser
else
  if hyprctl clients | grep -q "class: zen"; then
    hyprctl dispatch togglespecialworkspace browser
  else
    zen-browser
  fi
fi
