import QtQuick
import QtQuick.Controls.Basic

TextField {
    id: inputRoot

    readonly property color _backgroundColor: theme.state === "dark" ? Qt.alpha(theme.input, 0.15 * (inputRoot.hovered ? 0.5 : 0.3)) : "transparent"

    hoverEnabled: enabled
    selectByMouse: true
    opacity: enabled ? 1.0 : 0.5

    implicitWidth: 200
    implicitHeight: 32

    leftPadding: 10
    rightPadding: 10
    topPadding: 4
    bottomPadding: 4

    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    selectionColor: theme.primary
    selectedTextColor: theme.primaryForeground
    verticalAlignment: TextInput.AlignVCenter

    font.family: "Geist"
    font.pixelSize: 14
    font.weight: 400
    font.variableAxes: {
        "wght": 400,
        "opsz": 14
    }

    background: Item {
        Rectangle {
            x: -3
            y: -3
            width: parent.width + 6
            height: parent.height + 6
            radius: 13
            color: "transparent"
            border.width: 3
            border.color: Qt.alpha(theme.ring, 0.5)
            opacity: inputRoot.activeFocus ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: inputRoot._backgroundColor
            border.width: 1
            border.color: inputRoot.activeFocus ? theme.ring : theme.input

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
