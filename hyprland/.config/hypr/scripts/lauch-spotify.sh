#!/bin/bash

active_class=$(hyprctl activewindow | grep "class: " | cut -d' ' -f2)

if [[ "$active_class" == "spotify" ]]; then
  hyprctl dispatch workspace prev
else
  spotify-launcher
fi
