import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.singletons
import qs.components

MyPopover {
    id: systemMenuModuleRoot

    property real maxWidth: 148
    property real maxHeight: Screen.height * 0.6

    MyPopover.Anchor {
        MyIcon {
            source: "root:/assets/icons/arch.svg"
        }
    }

    ListModel {
        id: systemMenuModel

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
            }
        }
    }
}
