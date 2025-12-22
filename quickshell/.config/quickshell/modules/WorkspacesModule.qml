import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.components

Item {
  width: 134
  height: 24

  property var workspaceIcons: ({
    10: "root:/assets/icons/earth.svg", // browser
    11: "root:/assets/icons/music.svg", // spotify
    12: "root:/assets/icons/gamepad-2.svg" // steam
  })

  property var activeWorkspace: Hyprland.focusedWorkspace.id;
  property bool isSpecialWorkspace: activeWorkspace in workspaceIcons;

  RowLayout {
    anchors.fill: parent
    spacing: 8

    WorkspaceRect {
      active: activeWorkspace === 1
    }

    RowLayout {
      spacing: 8

      Layout.preferredWidth: activeWorkspace === 2 || activeWorkspace === 3 ? 98 : 28

      Behavior on Layout.preferredWidth {
        NumberAnimation {
          duration: 200
          easing.type: Easing.InOutQuad
        }
      }

      WorkspaceRect {
        active: activeWorkspace === 2
        visible: !isSpecialWorkspace
      }

      MyIcon {
        source: workspaceIcons[activeWorkspace]
        visible: isSpecialWorkspace

        Layout.alignment: Qt.AlignHCenter
      }

      WorkspaceRect {
        active: activeWorkspace === 3
        visible: !isSpecialWorkspace
      }
    }

    WorkspaceRect {
      active: activeWorkspace === 4
    }
  }

  component WorkspaceRect: Rectangle {
    property bool active: false;

    height: 10
    radius: 5
    color: theme.foreground
    
    Layout.fillWidth: true
    Layout.preferredWidth: active ? 80 : 10

    Behavior on Layout.preferredWidth {
      NumberAnimation {
        duration: 200
        easing.type: Easing.InOutQuad
      }
    }
  }
}