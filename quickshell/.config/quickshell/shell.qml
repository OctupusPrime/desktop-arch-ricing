import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.common
import qs.modules

ShellRoot {
  FontLoader {
    id: interFont
    source: "root:/assets/fonts/Inter.ttf"
  }
  
  Sizes { id: sizes }
  Theme { id: theme }
  Config { id: config }

  Variants {
    model: Quickshell.screens;

    Component {
      PanelWindow {
        id: panel
        required property var modelData

        anchors {
          bottom: true
          left: true
          right: true
        }

        implicitHeight: sizes.shellHeight
        color: theme.background

        RowLayout {
          spacing: 20

          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 20
          }

          CopilotModule {}
        }

        RowLayout {
          spacing: 20
          
          anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
          }

          SystemMenuModule {}

          WorkspacesModule {}

          AppsTrayModule {}
        }

        RowLayout {
          spacing: 16

          anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 6
          }

          KeyboardModule {}

          TimeModule {}
        }
      }
    }
  }
}