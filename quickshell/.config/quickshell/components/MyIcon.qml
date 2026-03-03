import QtQuick
import QtQuick.Effects

Item {
    id: iconRoot

    required property var source
    property int size: 24
    property color color: theme.foreground

    implicitWidth: size
    implicitHeight: size

    Image {
        anchors.fill: parent
        source: iconRoot.source

        sourceSize.width: iconRoot.size
        sourceSize.height: iconRoot.size
        fillMode: Image.PreserveAspectFit

        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: iconRoot.color
        }
    }
}
