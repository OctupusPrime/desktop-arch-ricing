import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.singletons
import qs.components

MyPopover {
    id: mediaMenuModuleRoot

    readonly property real maxWidth: 280
    readonly property real maxHeight: Screen.height * 0.6

    hideContentBackground: true
    onOpenedChanged: {
        if (mediaMenuModuleRoot.opened)
            return;

        mediaAccordion.collapseAll();
    }

    // Sinks

    readonly property bool hasSinks: MediaService.sinks.length > 0
    readonly property string sinkIcon: {
        if (!hasSinks)
            return icons.volumeX;
        if (MediaService.sinkMuted || MediaService.sinkVolume === 0)
            return icons.volumeX;
        if (MediaService.sinkVolume < 0.33)
            return icons.volume;
        if (MediaService.sinkVolume < 0.66)
            return icons.volume1;
        return icons.volume2;
    }

    // Sources

    readonly property bool hasSources: MediaService.sources.length > 0
    readonly property string sourceIcon: {
        if (!hasSources)
            return icons.micOff;
        if (MediaService.sourceMuted || MediaService.sourceVolume === 0)
            return icons.micOff;
        return icons.mic;
    }

    // Videos

    readonly property bool hasVideo: MediaService.video !== null
    readonly property string videoIcon: {
        if (!hasVideo)
            return icons.videoOff;
        if (MediaService.videoMuted)
            return icons.videoOff;
        return icons.video;
    }

    // Monitor

    readonly property var monitor: MonitorService.getMonitorForScreen(panel.screen)
    readonly property string brightnessIcon: {
        if (!monitor)
            return icons.sunDim;
        if (monitor.brightness < 0.33)
            return icons.sunDim;
        if (monitor.brightness < 0.66)
            return icons.sunMedium;
        return icons.sun;
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
                        source: mediaMenuModuleRoot.sinkIcon
                        opacity: mediaMenuModuleRoot.hasSinks ? 1 : 0.5
                        anchors.centerIn: parent
                    }
                }

                Item {
                    id: sourceTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    visible: mediaMenuModuleRoot.hasSources

                    property bool inUse: {
                        const node = MediaService.source;
                        if (!node)
                            return false;
                        return Pipewire.linkGroups.values.some(g => (g.source && g.source.id === node.id) || (g.target && g.target.id === node.id));
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: sourceTrackerRoot.inUse ? theme.primary : Qt.alpha(theme.primary, 0)
                        radius: 10
                    }

                    MyIcon {
                        size: 18
                        source: mediaMenuModuleRoot.sourceIcon
                        color: sourceTrackerRoot.inUse ? theme.primaryForeground : theme.foreground
                        anchors.centerIn: parent
                    }
                }

                Item {
                    id: videoTrackerRoot
                    implicitWidth: 22
                    implicitHeight: 22

                    visible: mediaMenuModuleRoot.hasVideo

                    property bool inUse: {
                        const node = MediaService.video;
                        if (!node)
                            return false;
                        return Pipewire.linkGroups.values.some(g => (g.source && g.source.id === node.id) || (g.target && g.target.id === node.id));
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: videoTrackerRoot.inUse ? theme.primary : Qt.alpha(theme.primary, 0)
                        radius: 10
                    }

                    MyIcon {
                        size: 18
                        source: mediaMenuModuleRoot.videoIcon
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
                                            source: mediaMenuModuleRoot.brightnessIcon
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

                                enabled: mediaMenuModuleRoot.hasSinks

                                triggerDelegate: Component {
                                    RowLayout {
                                        spacing: 6

                                        MyIcon {
                                            size: 18
                                            source: mediaMenuModuleRoot.sinkIcon
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

                                visible: mediaMenuModuleRoot.hasSources

                                triggerDelegate: Component {
                                    RowLayout {
                                        spacing: 6

                                        MyIcon {
                                            size: 18
                                            source: mediaMenuModuleRoot.sourceIcon
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

                            visible: mediaMenuModuleRoot.hasSources || mediaMenuModuleRoot.hasVideo
                        }

                        WrapperItem {
                            margin: 10
                            width: parent.width

                            visible: mediaMenuModuleRoot.hasSources || mediaMenuModuleRoot.hasVideo

                            RowLayout {
                                spacing: 10

                                MyButton {
                                    text: "Microphone"
                                    iconSource: icons.mic
                                    variant: MediaService.sourceMuted ? "secondary" : "primary"
                                    onClicked: MediaService.toggleSourceMute()

                                    visible: mediaMenuModuleRoot.hasSources

                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0
                                }
                                MyButton {
                                    text: "Camera"
                                    iconSource: icons.video
                                    variant: MediaService.videoMuted ? "secondary" : "primary"
                                    onClicked: MediaService.toggleVideoMute()

                                    visible: mediaMenuModuleRoot.hasVideo

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
                    source: ref.expanded ? icons.chevronUp : icons.chevronDown
                    anchors.centerIn: parent
                }
            }
        }
    }
}
