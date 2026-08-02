#!/bin/bash

active_class=$(hyprctl activewindow | grep "class: " | cut -d' ' -f2)

if [[ "$active_class" == "spotify" ]]; then
  hyprctl dispatch 'hl.dsp.focus({ workspace = "previous" })'
else
  spotify-launcher
fi
