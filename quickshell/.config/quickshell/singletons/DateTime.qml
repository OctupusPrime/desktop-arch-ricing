pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root

  readonly property string time: {
    Qt.formatTime(clock.date, "HH:mm")
  }
  readonly property string date: {
    Qt.formatDate(clock.date, "dd/MM/yyyy")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}