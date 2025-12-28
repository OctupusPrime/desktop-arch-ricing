import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

RowLayout {
  spacing: 6

  ColumnLayout {
    spacing: 0

    MyText {
      text: DateTimeService.time
      fontWeight: sizes.font.semibold

      Layout.alignment: Qt.AlignRight
    }

    MyText {
      text: DateTimeService.date
      fontSize: sizes.text.xs
      fontWeight: sizes.font.medium
      color: theme.mutedForeground

      Layout.alignment: Qt.AlignRight
    }
  }
}