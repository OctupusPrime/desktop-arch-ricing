import QtQuick
import QtQuick.Effects

Item {
    id: iconRoot

    required property var source
    property var size: 24
    property color color: theme.foreground

    width: size
    height: size

    Image {
        anchors.fill: parent
        source: iconRoot.source

        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: iconRoot.color
        }
    }
}
