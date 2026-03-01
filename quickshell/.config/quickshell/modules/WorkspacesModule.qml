import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.components

Item {
    id: workspacesModuleRoot

    width: 108
    height: 24

    readonly property int activeId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property bool hasIcon: activeId in config.workspaces.iconSubs

    RowLayout {
        anchors.fill: parent
        spacing: 8

        WorkspaceDot {
            wsId: 1
        }

        RowLayout {
            spacing: 8

            Layout.preferredWidth: workspacesModuleRoot.activeId === 2 || workspacesModuleRoot.activeId === 3 ? 76 : 24

            WorkspaceDot {
                visible: !workspacesModuleRoot.hasIcon
                wsId: 2
            }

            MyIcon {
                visible: workspacesModuleRoot.hasIcon
                source: workspacesModuleRoot.hasIcon ? Qt.resolvedUrl(config.workspaces.iconSubs[workspacesModuleRoot.activeId]) : ""
                Layout.alignment: Qt.AlignHCenter
            }

            WorkspaceDot {
                visible: !workspacesModuleRoot.hasIcon
                wsId: 3
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.Linear
                }
            }
        }

        WorkspaceDot {
            wsId: 4
        }
    }

    component WorkspaceDot: Rectangle {
        id: workDotRoot

        required property int wsId
        readonly property bool isActive: workspacesModuleRoot.activeId === wsId

        height: 8
        radius: 8
        color: theme.foreground
        Layout.fillWidth: true
        Layout.preferredWidth: isActive ? 60 : 8

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: 150
                easing.type: Easing.Linear
            }
        }
    }
}
