import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

RowLayout {
  spacing: 6

  ColumnLayout {
    spacing: 2

    MyText {
      text: DateTimeService.time
      fontSize: 14
      fontWeight: 600

      Layout.alignment: Qt.AlignRight
    }

      MyText {
      text: DateTimeService.date
      fontSize: 12
      color: theme.mutedForeground

      Layout.alignment: Qt.AlignRight
    }
  }
}