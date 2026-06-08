import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.common
import qs.modules

ShellRoot {
    FontLoader {
        id: geistFont
        source: "root:/assets/fonts/Geist.ttf"
    }
    FontLoader {
        id: iconsFont
        source: "root:/assets/fonts/Icons.ttf"
    }

    Theme {
        id: theme
    }
    Config {
        id: config
    }
    Icons {
        id: icons
    }

    Variants {
        model: Quickshell.screens

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

                implicitHeight: 44
                color: Qt.alpha(theme.background, 0.75)

                RowLayout {
                    spacing: 16

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 8
                    }

                    PiAgentModule {}
                }

                RowLayout {
                    spacing: 16

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

                    MediaMenuModule {}

                    KeyboardModule {}

                    TimeModule {}
                }
            }
        }
    }
}
