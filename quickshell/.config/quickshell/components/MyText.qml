import QtQuick

Text {
  property var fontSize: sizes.text.base
  property var fontWeight: sizes.font.normal

  font.family: interFont.name
  font.pixelSize: fontSize
  color: theme.foreground

  font.variableAxes: {
    "wght": fontWeight,
    "opsz": fontSize
  }
}