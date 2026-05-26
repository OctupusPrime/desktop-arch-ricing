import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls

import qs.singletons
import qs.components

AbstractButton {
    id: piAgentModuleRoot

    property bool isActive: HyprlandService.piAgentCliOpened || hovered || pressed

    hoverEnabled: true
    onClicked: {
        if (HyprlandService.piAgentCliOpened) {
            HyprlandService.closePiAgentCli();
        } else {
            HyprlandService.openPiAgentCli({
                x: 8,
                y: 8,
                width: 600,
                height: Screen.height - panel.height - 16
            });
        }
    }
    onHoveredChanged: {
        focusGrab.active = hovered;
    }

    background: Rectangle {
        color: piAgentModuleRoot.isActive ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.muted, 0)
        radius: 10

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    contentItem: Item {
        implicitWidth: 36
        implicitHeight: 36

        MyIcon {
            visible: !HyprlandService.piAgentCliOpened
            source: "root:/assets/icons/pi-agent.svg"
            anchors.centerIn: parent
        }

        MyIcon {
            visible: HyprlandService.piAgentCliOpened
            source: "root:/assets/icons/x.svg"
            anchors.centerIn: parent
        }
    }

    HyprlandFocusGrab {
        id: focusGrab

        windows: [panel]
    }
}
