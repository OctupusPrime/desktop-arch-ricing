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
            font.weight: sizes.font.semibold
            Layout.alignment: Qt.AlignRight
        }

        MyText {
            text: SystemService.date
            color: theme.mutedForeground
            font.pixelSize: sizes.text.xs
            font.weight: sizes.font.medium
            Layout.alignment: Qt.AlignRight
        }
    }
}
