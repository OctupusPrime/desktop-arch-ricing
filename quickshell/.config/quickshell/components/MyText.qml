import QtQuick

Text {
    id: textRoot

    color: theme.foreground
    font.family: geistFont.name
    font.pixelSize: 16
    font.weight: 400
    font.variableAxes: {
        "wght": font.weight,
        "opsz": font.pixelSize
    }
}
