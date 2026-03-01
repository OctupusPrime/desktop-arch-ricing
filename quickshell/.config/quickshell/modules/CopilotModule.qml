import Quickshell.Hyprland
import QtQuick

import qs.singletons
import qs.components

Item {
    id: copilotModuleRoot

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
                    x: 8,
                    y: 8,
                    width: 600,
                    height: Screen.height - panel.height - 16
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

                focusGrab.active = hovered;
            }
        }
    }
}
