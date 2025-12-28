import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.components

Item {
  width: 108
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

      Layout.preferredWidth: activeWorkspace === 2 || activeWorkspace === 3 ? 76 : 24

      Behavior on Layout.preferredWidth {
        NumberAnimation {
          duration: 150
          easing.type: Easing.Linear
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

    height: 8
    radius: sizes.rounded.full
    color: theme.foreground
    
    Layout.fillWidth: true
    Layout.preferredWidth: active ? 60 : 8

    Behavior on Layout.preferredWidth {
      NumberAnimation {
        duration: 150
        easing.type: Easing.Linear
      }
    }
  }
}