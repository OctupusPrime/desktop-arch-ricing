import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.singletons
import qs.components

MyPopover {
    id: root

    readonly property real maxWidth: 280
    readonly property real maxHeight: Screen.height * 0.6

    hideContentBackground: true

    onOpenedChanged: {
        if (!opened)
            mediaAccordion.collapseAll();
    }

    // SINKS
    readonly property bool hasSinks: PipewireService.sinks.length > 0

    readonly property string sinkIcon: {
        if (!hasSinks || PipewireService.sinkMuted || PipewireService.sinkVolume === 0)
            return icons.volumeX;
        if (PipewireService.sinkVolume < 0.33)
            return icons.volume;
        if (PipewireService.sinkVolume < 0.66)
            return icons.volume1;
        return icons.volume2;
    }

    // SOURCES
    readonly property bool hasSources: PipewireService.sources.length > 0

    readonly property string sourceIcon: !hasSources || PipewireService.sourceMuted || PipewireService.sourceVolume === 0 ? icons.micOff : icons.mic

    // CAMERAS
    readonly property bool hasCamera: PipewireService.cameraSupported

    readonly property string cameraIcon: !hasCamera || !PipewireService.cameraEnabled ? icons.videoOff : icons.video

    MyPopover.Anchor {
        AbstractButton {
            id: anchorButton

            property bool active: (root.opened && !root._isExiting) || hovered || pressed

            hoverEnabled: true
            onClicked: root.open()

            background: Rectangle {
                color: anchorButton.active ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.background, 0.5)

                radius: 20
                border.width: 1
                border.color: anchorButton.active ? theme.border : Qt.alpha(theme.border, 0)

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

                // AUDIO OUTPUT
                Item {
                    implicitWidth: 22
                    implicitHeight: 22

                    MyIcon {
                        anchors.centerIn: parent
                        size: 18
                        source: root.sinkIcon
                        opacity: root.hasSinks ? 1 : 0.5
                    }
                }

                // MICROPHONE
                Item {
                    implicitWidth: 22
                    implicitHeight: 22
                    visible: root.hasSources

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: PipewireService.microphoneInUse ? theme.primary : Qt.alpha(theme.primary, 0)
                    }

                    MyIcon {
                        anchors.centerIn: parent
                        size: 18
                        source: root.sourceIcon
                        color: PipewireService.microphoneInUse ? theme.primaryForeground : theme.foreground
                    }
                }

                // CAMERA
                Item {
                    implicitWidth: 22
                    implicitHeight: 22
                    visible: root.hasCamera

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: PipewireService.cameraInUse ? theme.primary : Qt.alpha(theme.primary, 0)
                    }

                    MyIcon {
                        anchors.centerIn: parent
                        size: 18
                        source: root.cameraIcon
                        color: PipewireService.cameraInUse ? theme.primaryForeground : theme.foreground
                    }
                }
            }
        }
    }

    MyPopover.Content {
        Item {
            width: root.maxWidth
            height: root.maxHeight

            Item {
                width: root.maxWidth
                height: Math.min(contentContainer.implicitHeight, root.maxHeight)
                anchors.bottom: parent.bottom

                MyPopover.Background {}

                ScrollView {
                    anchors.fill: parent

                    ScrollBar.vertical.policy: contentContainer.implicitHeight > root.maxHeight ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

                    Column {
                        id: contentContainer

                        width: root.maxWidth

                        MyAccordion {
                            id: mediaAccordion

                            type: "single"
                            contentPadding: 10
                            width: parent.width

                            // SINKS
                            MyAccordion.Content {
                                id: sinkAccordionItem

                                enabled: root.hasSinks

                                triggerDelegate: Component {
                                    Item {
                                        implicitHeight: sinkControls.implicitHeight

                                        RowLayout {
                                            id: sinkControls

                                            anchors.fill: parent
                                            spacing: 6

                                            MyIcon {
                                                size: 18
                                                source: root.sinkIcon
                                            }

                                            MySlider {
                                                id: sinkSlider

                                                to: 1
                                                value: PipewireService.sinkVolume
                                                onValueChanged: PipewireService.setSinkVolume(value)

                                                Layout.fillWidth: true
                                            }

                                            AccordionTriggerButton {
                                                ref: sinkAccordionItem
                                            }
                                        }
                                    }
                                }

                                contentDelegate: ColumnLayout {
                                    spacing: 8

                                    Repeater {
                                        model: PipewireService.sinks

                                        delegate: MyRadioButton {
                                            required property var modelData

                                            text: PipewireService.deviceName(modelData)

                                            checked: PipewireService.sink?.id === modelData.id

                                            onClicked: PipewireService.setAudioSink(modelData)

                                            Layout.fillWidth: true
                                            Layout.leftMargin: -4
                                            Layout.rightMargin: -4
                                        }
                                    }
                                }
                            }

                            // SOURCES
                            MyAccordion.Content {
                                id: sourceAccordionItem

                                visible: root.hasSources

                                triggerDelegate: Component {
                                    Item {
                                        implicitHeight: sourceControls.implicitHeight

                                        RowLayout {
                                            id: sourceControls

                                            anchors.fill: parent
                                            spacing: 6

                                            MyIcon {
                                                size: 18
                                                source: root.sourceIcon
                                            }

                                            MySlider {
                                                id: sourceSlider

                                                enabled: !PipewireService.sourceMuted
                                                opacity: enabled ? 1 : 0.4
                                                to: 1
                                                value: PipewireService.sourceVolume
                                                onValueChanged: PipewireService.setSourceVolume(value)

                                                Layout.fillWidth: true
                                            }

                                            AccordionTriggerButton {
                                                ref: sourceAccordionItem
                                            }
                                        }
                                    }
                                }

                                contentDelegate: ColumnLayout {
                                    spacing: 8

                                    Repeater {
                                        model: PipewireService.sources

                                        delegate: MyRadioButton {
                                            required property var modelData

                                            text: PipewireService.deviceName(modelData)

                                            checked: PipewireService.source?.id === modelData.id

                                            onClicked: PipewireService.setAudioSource(modelData)

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
                            visible: root.hasSources || root.hasCamera
                        }

                        // PRIVACY
                        WrapperItem {
                            margin: 10
                            width: parent.width
                            visible: root.hasSources || root.hasCamera

                            RowLayout {
                                spacing: 10

                                MyButton {
                                    text: "Microphone"

                                    iconSource: PipewireService.microphoneEnabled ? icons.mic : icons.micOff

                                    variant: PipewireService.microphoneEnabled ? "primary" : "secondary"

                                    onClicked: PipewireService.toggleMicrophoneEnabled()

                                    visible: root.hasSources

                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0
                                }

                                MyButton {
                                    text: "Camera"

                                    iconSource: PipewireService.cameraEnabled ? icons.video : icons.videoOff

                                    variant: PipewireService.cameraEnabled ? "primary" : "secondary"

                                    onClicked: PipewireService.toggleCameraEnabled()

                                    visible: root.hasCamera

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
                    anchors.centerIn: parent
                    size: 18
                    source: ref.expanded ? icons.chevronUp : icons.chevronDown
                }
            }
        }
    }
}
