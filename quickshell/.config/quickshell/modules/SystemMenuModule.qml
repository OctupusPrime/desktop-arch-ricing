import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.singletons
import qs.components

MyPopover {
    id: systemMenuModuleRoot

    MyPopover.Trigger {
        MyIcon {
            source: "root:/assets/icons/arch.svg"
        }
    }

    MyPopover.Content {
        WrapperItem {
            margin: 4
            width: 148

            ColumnLayout {
                spacing: 0

                MenuLabel {
                    text: "System"
                }
                MenuItem {
                    text: "Sleep mode"
                    onClicked: SystemService.sleep()
                }
                MenuItem {
                    text: "Shutdown"
                    onClicked: SystemService.shutdown()
                }
                MenuItem {
                    text: "Restart"
                    onClicked: SystemService.restart()
                }
            }
        }
    }

    component MenuLabel: WrapperItem {
        id: labelRoot

        property string text: ""

        topMargin: 6
        bottomMargin: 6
        leftMargin: 8
        rightMargin: 8
        Layout.fillWidth: true

        MyText {
            text: labelRoot.text
            fontSize: sizes.text.sm
            fontWeight: sizes.font.medium
            color: theme.popoverForeground
        }
    }

    component MenuItem: WrapperRectangle {
        id: menuItemRoot

        property string text: ""

        signal clicked

        color: hoverHandler.hovered ? theme.accent : "transparent"
        radius: sizes.rounded.sm
        topMargin: 6
        bottomMargin: 6
        leftMargin: 8
        rightMargin: 8
        Layout.fillWidth: true

        MyText {
            text: menuItemRoot.text
            fontSize: sizes.text.sm
            color: hoverHandler.hovered ? theme.accentForeground : theme.popoverForeground
        }

        HoverHandler {
            id: hoverHandler
        }

        TapHandler {
            onTapped: menuItemRoot.clicked()
        }
    }

    component Separator: Item {
        height: 9
        Layout.fillWidth: true
        Layout.leftMargin: -4
        Layout.rightMargin: -4

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: theme.border
        }
    }
}
