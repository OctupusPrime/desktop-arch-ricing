import QtQuick

Text {
  property var fontSize: 14
  property var fontWeight: 400

  font.family: interFont.name
  font.pixelSize: fontSize
  color: theme.foreground

  font.variableAxes: {
    "wght": fontWeight,
    "opsz": fontSize
  }
}