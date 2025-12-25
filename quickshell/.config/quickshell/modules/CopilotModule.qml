import Quickshell
import Quickshell.Hyprland
import QtQuick

import qs.singletons
import qs.components

Item {
  width: 24
  height: 24

  property int dialogWidth: 600;
  property int dialogHeight: 600;
  property var focusGrab: null;

  Item {
    visible: !HyprlandService.copilotCliOpened
    anchors.fill: parent

    MyIcon {
      source: "root:/assets/icons/copilot.svg"
    }

    TapHandler {
      onTapped: {
        Hyprland.dispatch(`exec [float; pin; move ${theme.hyprlandGaps} ${theme.hyprlandGaps}; size ${dialogWidth} ${dialogHeight}; animation slide left; opacity 0.9] kitty --class copilot-cli -o confirm_os_window_close=0 copilot`);
        // Positions the cusor to bottom left of the terminal
        Hyprland.dispatch(`movecursor ${theme.hyprlandGaps + 20} ${dialogHeight - 15}`)
      }
    }
  }

  Item {
    visible: HyprlandService.copilotCliOpened
    anchors.fill: parent

    MyIcon {
      source: "root:/assets/icons/x.svg"
    }

    TapHandler {
      onTapped: {
        Hyprland.dispatch("closewindow class:^(copilot-cli)$");
      }
    }

    HoverHandler {
      onHoveredChanged: {
        if (!focusGrab)
          return;

        if (hovered)
          focusGrab.active = true;
        else
          focusGrab.active = false;
      }
    }
  }
}