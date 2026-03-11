import QtQuick
import QtQuick.Controls.Basic

RadioButton {
    id: radioButtonRoot

    property int textPosition: Qt.RightEdge

    implicitHeight: 16
    spacing: 12

    indicator: Rectangle {
        implicitWidth: 16
        implicitHeight: 16

        x: radioButtonRoot.textPosition === Qt.RightEdge ? radioButtonRoot.leftPadding : radioButtonRoot.width - width - radioButtonRoot.rightPadding
        y: parent.height / 2 - height / 2

        radius: 8
        color: radioButtonRoot.checked ? theme.primary : theme.state === "dark" ? Qt.alpha(theme.input, 0.15 * 0.3) : Qt.alpha(theme.input, 0)
        border.color: radioButtonRoot.checked ? theme.primary : theme.input

        Rectangle {
            width: 8
            height: 8
            x: 4
            y: 4
            radius: 4
            color: theme.primaryForeground
            visible: radioButtonRoot.checked
        }
    }

    contentItem: MyText {
        text: radioButtonRoot.text
        fontSize: 14
        fontWeight: 500
        opacity: radioButtonRoot.enabled ? 1.0 : 0.5
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap

        leftPadding: radioButtonRoot.textPosition === Qt.RightEdge ? radioButtonRoot.indicator.implicitWidth + radioButtonRoot.spacing : 0
        rightPadding: radioButtonRoot.textPosition === Qt.LeftEdge ? radioButtonRoot.indicator.implicitWidth + radioButtonRoot.spacing : 0
    }
}
