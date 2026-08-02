#!/bin/bash

active_class=$(hyprctl activewindow | grep "class: " | cut -d' ' -f2)

if [[ "$active_class" == "zen" ]]; then
  hyprctl dispatch 'hl.dsp.focus({ workspace = "previous" })'
else
  if hyprctl clients | grep -q "class: zen"; then
    hyprctl dispatch 'hl.dsp.focus({ workspace = 10 })'
  else
    zen-browser
  fi
fi
