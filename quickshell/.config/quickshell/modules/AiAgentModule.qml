import QtQuick
import QtQuick.Controls

import qs.singletons
import qs.components

AbstractButton {
    id: aiAgentModuleRoot

    readonly property string agentCommand: "codex"
    property bool isActive: HyprlandService.aiAgentCliWindowId || hovered || pressed

    hoverEnabled: true
    onClicked: {
        if (!HyprlandService.aiAgentCliWindowId) {
            HyprlandService.openAiAgentCli({
                x: 8,
                y: 8,
                width: 600,
                height: Screen.height - panel.height - 16
            }, agentCommand);

            return;
        }
        HyprlandService.closeAiAgentCli();
    }

    background: Rectangle {
        color: aiAgentModuleRoot.isActive ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.muted, 0)
        radius: 10

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    contentItem: Item {
        implicitWidth: 36
        implicitHeight: 36

        MyIcon {
            visible: !HyprlandService.aiAgentCliWindowId
            source: icons.aiAgent
            anchors.centerIn: parent
        }

        MyIcon {
            visible: HyprlandService.aiAgentCliWindowId
            source: icons.x
            anchors.centerIn: parent
        }
    }
}
