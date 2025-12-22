import QtQuick
import QtQuick.Effects

Item {
  property var size: 24
  property var source: ""
  property color color: theme.foreground

  width: size
  height: size

  Image {
    id: iconImage
    anchors.fill: parent
    source: parent.source
    visible: false
  }

  MultiEffect {
    source: iconImage
    anchors.fill: iconImage
    colorization: 1.0
    colorizationColor: parent.color
  }
}