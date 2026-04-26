import QtQuick
import QtQuick.Controls

import qs.singletons
import qs.components

MyPopover {
    id: systemMenuModuleRoot

    property real maxWidth: 148
    property real maxHeight: Screen.height * 0.6

    MyPopover.Anchor {
        AbstractButton {
            id: anchorButtonRoot

            property bool isActive: (systemMenuModuleRoot.opened && !systemMenuModuleRoot._isExiting) || hovered || pressed

            hoverEnabled: true
            onClicked: systemMenuModuleRoot.open()

            background: Rectangle {
                color: anchorButtonRoot.isActive ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.muted, 0)
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
                    source: "root:/assets/icons/arch.svg"
                    anchors.centerIn: parent
                }
            }
        }
    }

    ListModel {
        id: systemMenuModel

        ListElement {
            type: "label"
            text: "Appearance"
        }
        ListElement {
            type: "appearanceItem"
            text: "Light"
            value: "light"
        }
        ListElement {
            type: "appearanceItem"
            text: "Adaptive"
            value: "auto"
        }
        ListElement {
            type: "appearanceItem"
            text: "Dark"
            value: "dark"
        }
        ListElement {
            type: "separator"
        }
        ListElement {
            type: "label"
            text: "System"
        }
        ListElement {
            type: "item"
            text: "Sleep mode"
            onClicked: function () {
                SystemService.sleep();
            }
        }
        ListElement {
            type: "item"
            text: "Shutdown"
            onClicked: function () {
                SystemService.shutdown();
            }
        }
        ListElement {
            type: "item"
            text: "Restart"
            onClicked: function () {
                SystemService.restart();
            }
        }
    }

    MyPopover.Content {
        ListView {
            id: contentListView

            property int margin: 4

            topMargin: margin
            bottomMargin: margin
            implicitWidth: systemMenuModuleRoot.maxWidth
            implicitHeight: Math.min(contentHeight + topMargin + bottomMargin, systemMenuModuleRoot.maxHeight)

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            model: systemMenuModel
            delegate: DelegateChooser {
                role: "type"

                DelegateChoice {
                    roleValue: "separator"

                    MyDropdown.MenuSeparator {}
                }
                DelegateChoice {
                    roleValue: "label"

                    MyDropdown.MenuLabel {
                        required property var modelData

                        anchors.leftMargin: contentListView.margin
                        anchors.rightMargin: contentListView.margin

                        text: modelData.text
                    }
                }
                DelegateChoice {
                    roleValue: "item"

                    MyDropdown.MenuItem {
                        required property var modelData

                        anchors.leftMargin: contentListView.margin
                        anchors.rightMargin: contentListView.margin

                        text: modelData.text
                        onClicked: modelData.onClicked()
                    }
                }
                DelegateChoice {
                    roleValue: "appearanceItem"

                    MyDropdown.MenuItem {
                        required property var modelData

                        anchors.leftMargin: contentListView.margin
                        anchors.rightMargin: contentListView.margin

                        text: modelData.text
                        buttonType: 2
                        checkState: SystemService.appearance === modelData.value ? 2 : 0
                        onClicked: {
                            SystemService.appearance = modelData.value;
                        }
                    }
                }
            }
        }
    }
}
