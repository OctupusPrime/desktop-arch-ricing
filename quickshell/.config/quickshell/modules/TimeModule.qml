import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

RowLayout {
    id: timeModuleRoot

    spacing: 6

    ColumnLayout {
        spacing: 0

        MyText {
            text: SystemService.time
            font.weight: 600
            Layout.alignment: Qt.AlignRight
        }

        MyText {
            text: SystemService.date
            color: theme.mutedForeground
            font.pixelSize: 12
            font.weight: 500
            Layout.alignment: Qt.AlignRight
        }
    }
}
