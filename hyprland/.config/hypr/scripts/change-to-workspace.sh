#!/bin/bash

# close special workspace on focused monitor if one is present
special_workspace=$(hyprctl -j monitors | awk '
    BEGIN { depth=0; special_depth=-1; current_special=""; is_focused=0; }
    /{/ { depth++ }
    /"specialWorkspace":/ { special_depth=depth }
    special_depth != -1 && /"name":/ {
        split($0, a, "\"");
        current_special = a[4];
        special_depth = -1;
    }
    /"focused": true/ { is_focused=1 }
    /}/ { 
        depth--;
        if (special_depth != -1 && depth < special_depth) { special_depth = -1; }
        if (depth == 0) { 
            if (is_focused && current_special != "") {
                print current_special;
                exit;
            }
            is_focused = 0;
            current_special = "";
        }
    }
')

hyprctl dispatch workspace "$1"

if [[ "$special_workspace" == *":"* ]]; then
    IFS=':' read -r -a parts <<< "$special_workspace"
    active="${parts[1]}"
    if [[ -n "$active" ]]; then
        hyprctl dispatch togglespecialworkspace "$active"
    fi
fi