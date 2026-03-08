import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.singletons
import qs.components

MyPopover {
    id: mediaMenuModuleRoot

    readonly property var monitor: MonitorService.getMonitorForScreen(panel.screen)

    property real maxWidth: 280
    property real maxHeight: Screen.height * 0.6

    hideContentBackground: true
    onOpenedChanged: {
        if (mediaMenuModuleRoot.opened)
            return;

        mediaAccordion.collapseAll();
    }

    MyPopover.Anchor {
        AbstractButton {
            id: anchorButtonRoot

            property bool isActive: (mediaMenuModuleRoot.opened && !mediaMenuModuleRoot._isExiting) || hovered || pressed

            hoverEnabled: true
            onClicked: mediaMenuModuleRoot.open()

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
                    id: sinkTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    MyIcon {
                        size: 18
                        source: MediaService.sinkIcon
                        anchors.centerIn: parent
                    }
                }

                Item {
                    id: sourceTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    PwNodeLinkTracker {
                        id: sourceLinkTracker
                        node: MediaService.source
                    }

                    property bool inUse: sourceLinkTracker.linkGroups.length > 0

                    Rectangle {
                        anchors.fill: parent
                        color: sourceTrackerRoot.inUse ? theme.primary : Qt.alpha(theme.primary, 0)
                        radius: 10
                    }

                    MyIcon {
                        size: 18
                        source: MediaService.sourceIcon
                        color: sourceTrackerRoot.inUse ? theme.primaryForeground : theme.foreground
                        anchors.centerIn: parent
                    }
                }

                Item {
                    id: videoTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    PwNodeLinkTracker {
                        id: videoLinkTracker
                        node: MediaService.video
                    }

                    property bool inUse: videoLinkTracker.linkGroups.length > 0

                    Rectangle {
                        anchors.fill: parent
                        color: videoTrackerRoot.inUse ? theme.primary : Qt.alpha(theme.primary, 0)
                        radius: 10
                    }

                    MyIcon {
                        size: 18
                        source: MediaService.videoIcon
                        color: videoTrackerRoot.inUse ? theme.primaryForeground : theme.foreground
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    MyPopover.Content {
        Item {
            width: mediaMenuModuleRoot.maxWidth
            height: mediaMenuModuleRoot.maxHeight

            MouseArea {
                anchors.fill: parent
                onClicked: mediaMenuModuleRoot.close()
            }

            Item {
                width: mediaMenuModuleRoot.maxWidth
                height: Math.min(contentContainer.implicitHeight, mediaMenuModuleRoot.maxHeight)
                anchors.bottom: parent.bottom

                MyPopover.Background {}

                ScrollView {
                    anchors.fill: parent
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Column {
                        id: contentContainer
                        width: mediaMenuModuleRoot.maxWidth

                        MyAccordion {
                            id: mediaAccordion
                            type: "single"
                            contentPadding: 10
                            width: parent.width

                            MyAccordion.Content {
                                id: brightnessAccordionItem

                                triggerDelegate: Component {
                                    RowLayout {
                                        spacing: 6

                                        MyIcon {
                                            size: 18
                                            source: "root:/assets/icons/sun.svg"
                                        }

                                        MySlider {
                                            value: mediaMenuModuleRoot.monitor.brightness
                                            onValueChanged: mediaMenuModuleRoot.monitor.setBrightness(value)

                                            Layout.fillWidth: true
                                        }

                                        Item {
                                            width: 18
                                        }
                                    }
                                }
                            }
                            MyAccordion.Content {
                                id: sinkAccordionItem

                                triggerDelegate: Component {
                                    RowLayout {
                                        spacing: 6

                                        MyIcon {
                                            size: 18
                                            source: MediaService.sinkIcon
                                        }

                                        MySlider {
                                            to: 1
                                            value: MediaService.sinkVolume
                                            onValueChanged: MediaService.setSinkVolume(value)

                                            Layout.fillWidth: true
                                        }

                                        Item {
                                            width: 18
                                            height: 18

                                            AbstractButton {
                                                z: 10
                                                anchors.fill: parent
                                                anchors.margins: -10

                                                onClicked: sinkAccordionItem.toggle()

                                                contentItem: Item {
                                                    MyIcon {
                                                        size: 18
                                                        source: sinkAccordionItem.expanded ? "root:/assets/icons/chevron-up.svg" : "root:/assets/icons/chevron-down.svg"
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                contentDelegate: Component {
                                    MyText {
                                        text: MediaService.sink.nickname
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }
                            MyAccordion.Content {
                                id: sourceAccordionItem

                                triggerDelegate: Component {
                                    RowLayout {
                                        spacing: 6

                                        MyIcon {
                                            size: 18
                                            source: MediaService.sourceIcon
                                        }

                                        MySlider {
                                            to: 1
                                            value: MediaService.sourceVolume
                                            onValueChanged: MediaService.setSourceVolume(value)

                                            Layout.fillWidth: true
                                        }

                                        Item {
                                            width: 18
                                            height: 18

                                            AbstractButton {
                                                z: 10
                                                anchors.fill: parent
                                                anchors.margins: -10

                                                onClicked: sourceAccordionItem.toggle()

                                                contentItem: Item {
                                                    MyIcon {
                                                        size: 18
                                                        source: sourceAccordionItem.expanded ? "root:/assets/icons/chevron-up.svg" : "root:/assets/icons/chevron-down.svg"
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                contentDelegate: Component {
                                    MyText {
                                        text: MediaService.source.nickname
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: theme.border
                        }

                        WrapperItem {
                            margin: 10
                            width: parent.width

                            RowLayout {
                                spacing: 10

                                MyButton {
                                    text: "Night Light"
                                    iconSource: "root:/assets/icons/sun-moon.svg"
                                    variant: "secondary"
                                    enabled: false

                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0
                                }
                                MyButton {
                                    text: "Camera"
                                    iconSource: "root:/assets/icons/video.svg"
                                    variant: "secondary"
                                    enabled: false

                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
