import Quickshell
import QtQuick
import QtQuick.Layouts

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
        id: panel
        required property var modelData
        screen: modelData

        anchors {
          bottom: true
          left: true
          right: true
        }

        implicitHeight: theme.shellHeight
        color: theme.background

        RowLayout {
          spacing: 22

          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 20
          }

          CopilotModule {
            dialogWidth: 600
            dialogHeight: screen.height - theme.shellHeight - (theme.hyprlandGaps * 2)
          }
        }

        RowLayout {
          spacing: 22
          
          anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
          }

          SystemMenuModule {}

          WorkspacesModule {}

          DBusMenuModule {}
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