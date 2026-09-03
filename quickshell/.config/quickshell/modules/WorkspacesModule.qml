import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

Item {
    id: root

    implicitWidth: 108
    implicitHeight: 24

    readonly property int activeWs: HyprlandService.activeWorkspaceId
    readonly property bool middleActive: activeWs === 2 || activeWs === 3

    readonly property var workspaceIcons: ({
            10: icons.earth,
            11: icons.music,
            12: icons.gamepad2
        })

    readonly property string activeIcon: workspaceIcons[activeWs] ?? ""
    readonly property bool showsIcon: activeIcon !== ""

    RowLayout {
        anchors.fill: parent
        spacing: 8

        WorkspaceDot {
            wsId: 1
        }

        RowLayout {
            spacing: 8
            Layout.preferredWidth: root.middleActive ? 76 : 24

            WorkspaceDot {
                visible: !root.showsIcon
                wsId: 2
            }

            QsIcon {
                visible: root.showsIcon
                source: root.activeIcon
                Layout.alignment: Qt.AlignHCenter
            }

            WorkspaceDot {
                visible: !root.showsIcon
                wsId: 3
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        WorkspaceDot {
            wsId: 4
        }
    }

    component WorkspaceDot: Rectangle {
        required property int wsId

        readonly property bool active: root.activeWs === wsId

        height: 8
        radius: height / 2
        color: theme.foreground

        Layout.fillWidth: true
        Layout.preferredWidth: active ? 60 : 8

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: 150
            }
        }
    }
}
