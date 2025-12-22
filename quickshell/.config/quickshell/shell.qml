import Quickshell
import QtQuick

import qs.common
import qs.modules

ShellRoot {
  Appearance { id: theme }

  FontLoader {
    id: interFont
    source: "root:/assets/fonts/Inter.ttf"
  }

  Variants {
    model: Quickshell.screens;

    Component {
      PanelWindow {
        required property var modelData

        screen: modelData

        anchors {
          bottom: true
          left: true
          right: true
        }

        implicitHeight: 46

        color: theme.background

        WorkspacesModule {
          anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
          }
        }

        TimeModule {
          anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 6
          }
        }
      }
    }
  }
}