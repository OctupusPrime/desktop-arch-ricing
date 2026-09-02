import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

Item {
    id: dialogRoot

    property bool opened: false
    property bool _isExiting: false

    property bool hasActiveChild: false
    property var activePopup: null

    function open() {
        dialogRoot.opened = true;
    }
    function close() {
        dialogRoot._isExiting = true;
    }
    function toggle() {
        dialogRoot.opened ? dialogRoot.close() : dialogRoot.open();
    }
    function terminate() {
        dialogRoot.opened = false;
        dialogRoot._isExiting = false;
    }

    default property list<QtObject> _items
    property Item _content: null

    Component.onCompleted: {
        for (let i = 0; i < _items.length; i++) {
            if (_items[i] instanceof Item) {
                _content = _items[i];
                break;
            }
        }
    }

    LazyLoader {
        id: dialogLoader
        active: dialogRoot.opened

        QtObject {
            property var focusGrab: HyprlandFocusGrab {
                windows: dialogRoot.activePopup ? [dialogRoot.activePopup] : []
                active: dialogRoot.opened && !dialogRoot._isExiting && !dialogRoot.hasActiveChild
                onCleared: {
                    if (dialogRoot.hasActiveChild)
                        return;
                    dialogRoot.close();
                }
            }

            property var window: PanelWindow {
                id: dialogFullscreenPanel

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

                    implicitWidth: dialogFullscreenPanel.screen.width
                    implicitHeight: dialogFullscreenPanel.screen.height
                    anchor.window: dialogFullscreenPanel
                    anchor.adjustment: PopupAdjustment.None

                    Component.onCompleted: dialogRoot.activePopup = dialogPopup
                    Component.onDestruction: dialogRoot.activePopup = null

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

                        transitions: [
                            Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        ]
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (dialogRoot.hasActiveChild)
                                return;
                            dialogRoot.close();
                        }
                    }

                    Item {
                        id: contentContainer

                        implicitWidth: dialogRoot._content ? dialogRoot._content.implicitWidth : 100
                        implicitHeight: dialogRoot._content ? dialogRoot._content.implicitHeight : 100

                        anchors.centerIn: parent
                        opacity: 0
                        scale: 0.95
                        transformOrigin: Item.Center

                        MouseArea {
                            anchors.fill: parent
                        }

                        states: [
                            State {
                                name: "visible"
                                when: dialogRoot.opened && !dialogRoot._isExiting
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
                                from: "visible"
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
                        }

                        Binding {
                            target: dialogRoot._content
                            property: "parent"
                            value: contentContainer
                        }
                    }
                }
            }
        }
    }
}
