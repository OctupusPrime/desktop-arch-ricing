import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.components

MyPopover {
    id: appsTrayModuleRoot

    showBackground: false
    property real maxHeight: Screen.height * 0.4
    property string activeAppId: ""
    property alias menuStack: trayMenuStackView

    onTerminated: {
        menuStack.clear();
        activeAppId = "";
    }

    MyPopover.Trigger {
        MyIcon {
            source: "root:/assets/icons/boxes.svg"
        }
    }

    MyPopover.Content {
        ColumnLayout {
            spacing: 8

            StackView {
                id: trayMenuStackView

                width: 184
                implicitHeight: appsTrayModuleRoot.maxHeight

                replaceEnter: null
                replaceExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        to: 0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: appsTrayModuleRoot.close()
                }
            }

            Item {
                property int margin: 4
                property int minSize: 32

                implicitWidth: Math.max(minSize, appsGridContainer.implicitWidth) + (margin * 2)
                implicitHeight: Math.max(minSize, appsGridContainer.implicitHeight) + (margin * 2)
                Layout.alignment: Qt.AlignCenter

                MyPopover.Background {}

                Grid {
                    id: appsGridContainer

                    anchors.fill: parent
                    anchors.margins: parent.margin
                    columns: Math.min(appsGridRepeater.count, 5)
                    spacing: 4

                    Repeater {
                        id: appsGridRepeater

                        model: SystemTray.items
                        delegate: AppItem {
                            required property SystemTrayItem modelData

                            appId: modelData.id
                            icon: modelData.icon
                            active: appsTrayModuleRoot.activeAppId === modelData.id

                            onClicked: {
                                appsTrayModuleRoot.menuStack.replace(trayMenuFactory, {
                                    modelData: modelData
                                });
                                appsTrayModuleRoot.activeAppId = modelData.id;
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: trayMenuFactory

        ColumnLayout {
            id: trayMenuRoot

            required property SystemTrayItem modelData

            Item {
                id: trayMenuContainer

                readonly property bool hasContent: traySubMenuStack.currentItem && traySubMenuStack.currentItem.implicitHeight > 0

                implicitHeight: hasContent ? traySubMenuStack.currentItem.implicitHeight : 0
                transformOrigin: Item.Bottom
                opacity: 0
                scale: 0.95
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true

                states: [
                    State {
                        name: "visible"
                        when: trayMenuContainer.hasContent
                        PropertyChanges {
                            trayMenuContainer {
                                opacity: 1
                                scale: 1
                            }
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "*"
                        to: "visible"
                        ParallelAnimation {
                            NumberAnimation {
                                property: "opacity"
                                duration: 200
                            }
                            NumberAnimation {
                                property: "scale"
                                duration: 250
                                easing.type: Easing.OutBack
                            }
                        }
                    }
                ]

                MyPopover.Background {}

                MouseArea {
                    anchors.fill: parent
                }

                StackView {
                    id: traySubMenuStack

                    anchors.fill: parent
                    clip: true

                    Component.onCompleted: {
                        traySubMenuStack.push(traySubMenuFactory, {
                            handle: trayMenuRoot.modelData.menu,
                            isSubMenu: false
                        });
                    }
                    Component.onDestruction: {
                        traySubMenuStack.clear();
                    }

                    pushEnter: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 1
                        }
                        PropertyAnimation {
                            property: "x"
                            from: traySubMenuStack.width
                            to: 0
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    pushExit: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 0
                        }
                        PropertyAnimation {
                            property: "x"
                            from: 0
                            to: -traySubMenuStack.width
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    popEnter: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 1
                        }
                        PropertyAnimation {
                            property: "x"
                            from: -traySubMenuStack.width
                            to: 0
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    popExit: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 0
                        }
                        PropertyAnimation {
                            property: "x"
                            from: 0
                            to: traySubMenuStack.width
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Component {
        id: traySubMenuFactory

        ListView {
            id: traySubMenuRoot

            required property QsMenuHandle handle
            property bool isSubMenu: true
            property int margin: 4

            implicitHeight: contentHeight > 0 ? Math.min(contentHeight + topMargin + bottomMargin, appsTrayModuleRoot.maxHeight) : 0
            topMargin: margin
            bottomMargin: isSubMenu ? 48 : margin
            leftMargin: margin
            rightMargin: margin
            layer.enabled: StackView.view ? StackView.view.busy : false
            layer.smooth: true

            QsMenuOpener {
                id: traySubMenuOpener

                menu: traySubMenuRoot.handle
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            model: traySubMenuOpener.children
            delegate: DelegateChooser {
                role: "isSeparator"

                DelegateChoice {
                    roleValue: true

                    Item {
                        width: traySubMenuRoot.width
                        height: childrenRect.height

                        MenuSeparator {
                            width: parent.width
                            x: -traySubMenuRoot.leftMargin
                        }
                    }
                }

                DelegateChoice {
                    roleValue: false

                    MenuItem {
                        required property var modelData

                        width: traySubMenuRoot.width - traySubMenuRoot.leftMargin - traySubMenuRoot.rightMargin

                        text: modelData.text
                        enabled: modelData.enabled
                        hasChildren: modelData.hasChildren
                        buttonType: modelData.buttonType
                        checkState: modelData.checkState

                        onClicked: {
                            if (modelData.hasChildren) {
                                traySubMenuRoot.StackView.view.push(traySubMenuFactory, {
                                    handle: modelData,
                                    isSubMenu: true
                                });
                                return;
                            }

                            modelData.triggered();

                            if (modelData.buttonType === QsMenuButtonType.None)
                                appsTrayModuleRoot.close();
                        }
                    }
                }
            }

            CloseSubMenuButton {
                visible: traySubMenuRoot.isSubMenu
                width: traySubMenuRoot.width
                anchors.bottom: parent.bottom
                z: 10
                onClicked: traySubMenuRoot.StackView.view.pop()
            }
        }
    }

    component AppItem: Rectangle {
        id: appItemRoot

        required property var appId
        property string icon
        property bool active

        signal clicked

        width: 32
        height: 32
        color: appItemHover.hovered || active ? theme.accent : "transparent"
        radius: 4

        function getIconSource(id: string, pathname: string): string {
            if (id in config.tray.iconSubs) {
                return Qt.resolvedUrl(config.tray.iconSubs[id]);
            }

            if (pathname.includes("?path=")) {
                const [name, path] = pathname.split("?path=");
                return Qt.resolvedUrl(`${path}/${name.slice(name.lastIndexOf("/") + 1)}`);
            }
            return pathname;
        }

        Image {
            id: appItemIcon

            width: 20
            height: 20
            anchors.centerIn: parent
            source: appItemRoot.getIconSource(appItemRoot.appId, appItemRoot.icon)
            sourceSize: Qt.size(20, 20)
        }

        HoverHandler {
            id: appItemHover
        }
        TapHandler {
            onTapped: appItemRoot.clicked()
        }
    }

    component MenuSeparator: Item {
        id: menuSeparatorRoot

        Layout.fillWidth: true
        height: 9

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: theme.border
        }
    }

    component MenuItem: WrapperRectangle {
        id: trayMenuItemRoot

        property string text: ""
        property bool enabled: true
        property bool hasChildren: false
        property var buttonType: QsMenuButtonType.None
        property var checkState: 0 // 0: unchecked, 1: partially checked, 2: checked

        signal clicked

        color: trayMenuItemHover.hovered ? theme.accent : "transparent"
        radius: 4
        opacity: enabled ? 1 : 0.5
        topMargin: 6
        bottomMargin: 6
        leftMargin: 8
        rightMargin: 8
        Layout.fillWidth: true

        RowLayout {
            spacing: 6

            MyText {
                text: trayMenuItemRoot.text
                color: theme.popoverForeground
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            MyIcon {
                visible: trayMenuItemRoot.hasChildren
                source: "root:/assets/icons/chevron-right.svg"
                size: 16
            }

            MyIcon {
                visible: trayMenuItemRoot.buttonType !== QsMenuButtonType.None && trayMenuItemRoot.checkState > 0
                source: "root:/assets/icons/check.svg"
                size: 16
            }
        }

        HoverHandler {
            id: trayMenuItemHover

            enabled: trayMenuItemRoot.enabled
        }

        TapHandler {
            enabled: trayMenuItemRoot.enabled
            onTapped: trayMenuItemRoot.clicked()
        }
    }

    component CloseSubMenuButton: Item {
        id: closeSubMenuButtonRoot

        signal clicked

        height: 48
        Layout.fillWidth: true

        Rectangle {
            anchors.fill: parent
            radius: 8
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "transparent"
                }
                GradientStop {
                    position: 1
                    color: theme.popover
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onWheel: wheel.accepted = true
        }

        Rectangle {
            id: buttonWrapper

            width: backButton.width
            height: backButton.height
            radius: 8
            color: theme.background
            anchors.centerIn: parent

            MyButton {
                id: backButton

                size: "sm"
                variant: "secondary"
                text: "Back"
                anchors.fill: parent
                onClicked: closeSubMenuButtonRoot.clicked()
            }
        }
    }
}
