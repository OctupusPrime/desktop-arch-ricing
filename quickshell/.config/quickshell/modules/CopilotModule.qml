import Quickshell.Hyprland
import QtQuick

import qs.singletons
import qs.components

Item {
  width: 24
  height: 24

  HyprlandFocusGrab {
    id: focusGrab
    windows: [panel]
  }


  Item {
    visible: !HyprlandService.copilotCliOpened
    anchors.fill: parent

    MyIcon {
      source: "root:/assets/icons/copilot.svg"
    }

    TapHandler {
      onTapped: {
        HyprlandService.openCopilotCli({
          x: sizes.hyprlOffset, 
          y: sizes.hyprlOffset, 
          width: 600, 
          height: screen.height - panel.height - (sizes.hyprlOffset * 2)
        });
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
      onTapped: HyprlandService.closeCopilotCli()
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