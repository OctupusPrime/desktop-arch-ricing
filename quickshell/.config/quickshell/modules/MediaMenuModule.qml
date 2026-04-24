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

            Item {
                width: mediaMenuModuleRoot.maxWidth
                height: Math.min(contentContainer.implicitHeight, mediaMenuModuleRoot.maxHeight)
                anchors.bottom: parent.bottom

                MyPopover.Background {}

                ScrollView {
                    anchors.fill: parent
                    ScrollBar.vertical.policy: {
                        if (contentContainer.implicitHeight > mediaMenuModuleRoot.maxHeight)
                            return ScrollBar.AsNeeded;
                        else
                            return ScrollBar.AlwaysOff;
                    }

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
                                            source: mediaMenuModuleRoot.monitor.brightnessIcon
                                        }

                                        MySlider {
                                            to: 1
                                            value: mediaMenuModuleRoot.monitor.brightness
                                            onValueChanged: mediaMenuModuleRoot.monitor.setBrightness(value)
                                            Layout.fillWidth: true
                                        }

                                        AccordionTriggerButton {
                                            ref: brightnessAccordionItem
                                        }
                                    }
                                }
                                contentDelegate: ColumnLayout {
                                    spacing: 8

                                    MySwitch {
                                        text: "Night Shift"
                                        textPosition: Qt.LeftEdge
                                        checked: MonitorService.nightShiftEnabled
                                        onCheckedChanged: MonitorService.toggleNightShift()

                                        Layout.fillWidth: true
                                        Layout.leftMargin: -4
                                        Layout.rightMargin: -4
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

                                        AccordionTriggerButton {
                                            ref: sinkAccordionItem
                                        }
                                    }
                                }
                                contentDelegate: ColumnLayout {
                                    spacing: 8

                                    Repeater {
                                        model: MediaService.sinks
                                        delegate: MyRadioButton {
                                            required property var modelData

                                            text: modelData.nickname ?? modelData.description ?? modelData.name ?? "Unknown"
                                            checked: MediaService.sink ? modelData.id === MediaService.sink.id : false
                                            onClicked: MediaService.setAudioSink(modelData)

                                            Layout.fillWidth: true
                                            Layout.leftMargin: -4
                                            Layout.rightMargin: -4
                                        }
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

                                        AccordionTriggerButton {
                                            ref: sourceAccordionItem
                                        }
                                    }
                                }
                                contentDelegate: ColumnLayout {
                                    spacing: 8

                                    Repeater {
                                        model: MediaService.sources
                                        delegate: MyRadioButton {
                                            required property var modelData

                                            text: modelData.nickname ?? modelData.description ?? modelData.name ?? "Unknown"
                                            checked: MediaService.source ? modelData.id === MediaService.source.id : false
                                            onClicked: MediaService.setAudioSource(modelData)

                                            Layout.fillWidth: true
                                            Layout.leftMargin: -4
                                            Layout.rightMargin: -4
                                        }
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
                                    text: "Microphone"
                                    iconSource: "root:/assets/icons/mic.svg"
                                    variant: MediaService.sourceMuted ? "secondary" : "primary"
                                    onClicked: MediaService.toggleSourceMute()

                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0
                                }
                                MyButton {
                                    text: "Camera"
                                    iconSource: "root:/assets/icons/video.svg"
                                    variant: MediaService.videoMuted || !MediaService.video ? "secondary" : "primary"
                                    onClicked: MediaService.toggleVideoMute()
                                    enabled: MediaService.video !== null

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

    component AccordionTriggerButton: Item {
        id: triggerButtonRoot

        required property var ref

        width: 18
        height: 18

        AbstractButton {
            z: 10
            anchors.fill: parent
            anchors.margins: -10

            onClicked: ref.toggle()

            contentItem: Item {
                MyIcon {
                    size: 18
                    source: ref.expanded ? "root:/assets/icons/chevron-up.svg" : "root:/assets/icons/chevron-down.svg"
                    anchors.centerIn: parent
                }
            }
        }
    }
}
