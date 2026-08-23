import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.singletons
import qs.components

MyPopover {
    id: connectionMenuModuleRoot

    readonly property real maxWidth: 280
    readonly property real maxHeight: Screen.height * 0.6

    MyPopover.Anchor {
        AbstractButton {
            id: anchorButtonRoot

            property bool isActive: (connectionMenuModuleRoot.opened && !connectionMenuModuleRoot._isExiting) || hovered || pressed

            hoverEnabled: true
            onClicked: connectionMenuModuleRoot.open()

            background: Rectangle {
                color: anchorButtonRoot.isActive ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.background, 0.5)
                radius: 20
                border.width: 1
                border.color: anchorButtonRoot.isActive ? theme.border : Qt.alpha(theme.border, 0)

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            contentItem: Row {
                spacing: 4
                padding: 6

                Item {
                    id: wifiTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    MyIcon {
                        size: 18
                        source: icons.wifi
                        anchors.centerIn: parent
                    }
                }

                Item {
                    id: bluetoothTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    MyIcon {
                        size: 18
                        source: icons.bluetooth
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    MyPopover.Content {}
}
