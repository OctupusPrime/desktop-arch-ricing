import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.components

Item {
  id: workspacesModuleRoot

  width: 108
  height: 24

  readonly property var workspaceIcons: ({
    10: "root:/assets/icons/earth.svg", // browser
    11: "root:/assets/icons/music.svg", // spotify
    12: "root:/assets/icons/gamepad-2.svg" // steam
  })

  readonly property int activeId: Hyprland.focusedWorkspace?.id ?? 1
  readonly property bool hasIcon: activeId in workspaceIcons

  RowLayout {
    anchors.fill: parent
    spacing: 8

    WorkspaceDot { wsId: 1 }

    RowLayout {
      spacing: 8

      Layout.fillWidth: true
      Layout.preferredWidth: workspacesModuleRoot.activeId === 2 || workspacesModuleRoot.activeId === 3 ? 76 : 24

      WorkspaceDot { 
        visible: !workspacesModuleRoot.hasIcon
        wsId: 2
      }

      MyIcon {
        visible: workspacesModuleRoot.hasIcon
        source: workspacesModuleRoot.hasIcon ? workspacesModuleRoot.workspaceIcons[workspacesModuleRoot.activeId] : ""

        Layout.alignment: Qt.AlignHCenter
      }

      WorkspaceDot {
        visible: !workspacesModuleRoot.hasIcon 
        wsId: 3 
      }

      Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 150; easing.type: Easing.Linear }
      }
    }

    WorkspaceDot { wsId: 4 }
  }

  component WorkspaceDot: Rectangle {
    required property int wsId
    readonly property bool isActive: workspacesModuleRoot.activeId === wsId

    height: 8
    radius: sizes.rounded.full
    color: theme.foreground
    
    Layout.fillWidth: true
    Layout.preferredWidth: isActive ? 60 : 8

    Behavior on Layout.preferredWidth {
      NumberAnimation { duration: 150; easing.type: Easing.Linear }
    }
  }
}