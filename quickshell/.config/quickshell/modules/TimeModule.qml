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
            fontWeight: sizes.font.semibold
            Layout.alignment: Qt.AlignRight
        }

        MyText {
            text: SystemService.date
            fontSize: sizes.text.xs
            fontWeight: sizes.font.medium
            color: theme.mutedForeground
            Layout.alignment: Qt.AlignRight
        }
    }
}
