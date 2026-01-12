pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtPositioning

Singleton {
  id: systemService

  readonly property string time: {
    Qt.formatTime(systemClock.date, "HH:mm")
  }
  readonly property string date: {
    Qt.formatDate(systemClock.date, "dd/MM/yyyy")
  }

  property QtObject geolocation: QtObject {
    property double lat: 0.0
    property double lon: 0.0
    property bool ready: false
  }

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }

  PositionSource {
    id: positionSource
    active: false

    onPositionChanged: {
      var coord = position.coordinate;
      if (!coord.isValid) {
        console.warn("Invalid coordinates received from PositionSource");
        return;
      }

      systemService.geolocation.lat = coord.latitude;
      systemService.geolocation.lon = coord.longitude;
      systemService.geolocation.ready = true;
    }
  }

  Process {
    id: systemProcess
  }

  function shutdown() {
    systemProcess.exec(["sh", "-c", "systemctl poweroff"]);
  }

  function restart() {
    systemProcess.exec(["sh", "-c", "systemctl reboot"]);
  }

  function sleep() {
    systemProcess.exec(["sh", "-c", "systemctl suspend"]);
  }

  Component.onCompleted: {
    positionSource.update();
  }
}