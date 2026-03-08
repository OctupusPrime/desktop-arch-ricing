import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

ColumnLayout {
    id: timeModuleRoot

    spacing: 0

    MyText {
        text: SystemService.time
        fontWeight: 600
        Layout.alignment: Qt.AlignRight
    }

    MyText {
        text: SystemService.date
        color: theme.mutedForeground
        fontSize: 12
        fontWeight: 500
        Layout.alignment: Qt.AlignRight
    }
}
