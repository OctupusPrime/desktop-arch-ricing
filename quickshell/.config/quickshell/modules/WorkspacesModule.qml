import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.components

Item {
    id: workspacesModuleRoot

    implicitWidth: 108
    implicitHeight: 24

    readonly property var iconByWorkspaceId: ({
            10: icons.earth,
            11: icons.music,
            12: icons.gamepad2
        })

    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property string activeIcon: iconByWorkspaceId[activeWorkspaceId] ?? ""
    readonly property bool showsIcon: activeIcon.length > 0

    RowLayout {
        anchors.fill: parent
        spacing: 8

        WorkspaceDot {
            wsId: 1
        }

        RowLayout {
            spacing: 8

            Layout.preferredWidth: workspacesModuleRoot.activeWorkspaceId === 2 || workspacesModuleRoot.activeWorkspaceId === 3 ? 76 : 24

            WorkspaceDot {
                visible: !workspacesModuleRoot.showsIcon
                wsId: 2
            }

            MyIcon {
                visible: workspacesModuleRoot.showsIcon
                source: workspacesModuleRoot.activeIcon
                Layout.alignment: Qt.AlignHCenter
            }

            WorkspaceDot {
                visible: !workspacesModuleRoot.showsIcon
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
        readonly property bool isActive: workspacesModuleRoot.activeWorkspaceId === wsId

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
