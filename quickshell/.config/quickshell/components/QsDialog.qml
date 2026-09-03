import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick

Item {
    id: dialogRoot

    property Component content

    property bool opened: false
    property bool _isExiting: false

    property var activePopup: null
    property bool hasActiveChild: false

    function open(): void {
        if (opened)
            return;

        _isExiting = false;
        opened = true;
    }

    function close(): void {
        if (opened && !_isExiting)
            _isExiting = true;
    }

    function toggle(): void {
        opened ? close() : open();
    }

    function terminate(): void {
        opened = false;
        _isExiting = false;
    }

    // DIALOG
    LazyLoader {
        id: dialogLoader

        active: dialogRoot.opened

        QtObject {
            property var focusGrab: HyprlandFocusGrab {
                windows: dialogRoot.activePopup ? [dialogRoot.activePopup] : []

                active: dialogRoot.opened && !dialogRoot._isExiting && !dialogRoot.hasActiveChild

                onCleared: {
                    if (!dialogRoot.hasActiveChild)
                        dialogRoot.close();
                }
            }

            property var window: PanelWindow {
                id: fullscreenPanel

                color: "transparent"
                exclusionMode: ExclusionMode.Ignore

                WlrLayershell.layer: WlrLayer.Overlay

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                PopupWindow {
                    id: dialogPopup

                    visible: true
                    color: "transparent"

                    implicitWidth: fullscreenPanel.screen.width
                    implicitHeight: fullscreenPanel.screen.height

                    anchor.window: fullscreenPanel
                    anchor.adjustment: PopupAdjustment.None

                    Component.onCompleted: dialogRoot.activePopup = dialogPopup

                    Component.onDestruction: {
                        if (dialogRoot.activePopup === dialogPopup)
                            dialogRoot.activePopup = null;
                    }

                    // BACKDROP
                    Rectangle {
                        id: backdrop

                        anchors.fill: parent
                        color: "black"
                        opacity: 0

                        states: [
                            State {
                                name: "visible"

                                when: dialogRoot.opened && !dialogRoot._isExiting

                                PropertyChanges {
                                    backdrop.opacity: 0.7
                                }
                            },
                            State {
                                name: "hidden"
                                when: dialogRoot._isExiting

                                PropertyChanges {
                                    backdrop.opacity: 0
                                }
                            }
                        ]

                        transitions: Transition {
                            NumberAnimation {
                                property: "opacity"
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // CLOSE AREA
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (!dialogRoot.hasActiveChild)
                                dialogRoot.close();
                        }
                    }

                    // CONTENT
                    Item {
                        id: contentContainer

                        readonly property bool contentReady: contentLoader.item !== null

                        implicitWidth: contentReady ? contentLoader.item?.implicitWidth ?? 100 : 100

                        implicitHeight: contentReady ? contentLoader.item?.implicitHeight ?? 100 : 100

                        anchors.centerIn: parent

                        opacity: 0
                        scale: 0.95
                        transformOrigin: Item.Center

                        MouseArea {
                            anchors.fill: parent
                        }

                        LazyLoader {
                            id: contentLoader

                            activeAsync: dialogRoot.opened
                            component: dialogRoot.content
                        }

                        Binding {
                            target: contentLoader.item

                            property: "parent"
                            value: contentContainer
                        }

                        states: [
                            State {
                                name: "visible"

                                when: dialogRoot.opened && !dialogRoot._isExiting && contentContainer.contentReady

                                PropertyChanges {
                                    contentContainer {
                                        opacity: 1
                                        scale: 1
                                    }
                                }
                            },
                            State {
                                name: "hidden"
                                when: dialogRoot._isExiting

                                PropertyChanges {
                                    contentContainer {
                                        opacity: 0
                                        scale: 0.95
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
                                        easing.type: Easing.OutCubic
                                    }

                                    NumberAnimation {
                                        property: "scale"
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            },
                            Transition {
                                from: "*"
                                to: "hidden"

                                SequentialAnimation {
                                    ParallelAnimation {
                                        NumberAnimation {
                                            property: "opacity"
                                            duration: 150
                                            easing.type: Easing.InCubic
                                        }

                                        NumberAnimation {
                                            property: "scale"
                                            duration: 150
                                            easing.type: Easing.InCubic
                                        }
                                    }

                                    ScriptAction {
                                        script: dialogRoot.terminate()
                                    }
                                }
                            }
                        ]

                        Rectangle {
                            anchors.fill: parent

                            color: theme.popover
                            radius: 10

                            border.color: theme.border
                            border.width: 1

                            z: -1
                        }
                    }
                }
            }
        }
    }
}
