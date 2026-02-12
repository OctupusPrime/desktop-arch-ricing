pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtCore
import QtPositioning

Singleton {
  id: systemService

  readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/scripts/"

  Process {
    id: systemProc
  }

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }

  readonly property string time: {
    Qt.formatTime(systemClock.date, "HH:mm")
  }
  readonly property string date: {
    Qt.formatDate(systemClock.date, "dd/MM/yyyy")
  }

  property QtObject geo: QtObject {
    id: geoObject
    property double lat: -1
    property double lon: -1
  }

  property string timezone: "UTC"
  
  onTimezoneChanged: {
    systemProc.exec({
      command: [
        systemService.scriptsDir + "change-timezone.sh",
        timezone
      ]
    })
  }

  property QtObject solar: QtObject {
    id: solarObject
    property int sunrise: 480  // Default to 8:00
    property int sunset: 1080  // Default to 18:00
  }

  property string appearance: "system" // "light" | "system" | "dark"

  property string theme: {
    if (systemService.appearance === "system") {
      const totalMinutes = systemClock.date.getHours() * 60 + systemClock.date.getMinutes();
      const isDaytime = totalMinutes >= systemService.solar.sunrise && totalMinutes < systemService.solar.sunset;  

      return isDaytime ? "light" : "dark"
    }

    return systemService.appearance
  }

  onThemeChanged: {
    systemProc.exec({
      command: [
        systemService.scriptsDir + "change-color-theme.sh",
        theme
      ]
    })
  }

  Settings {
    category: "System"

    property alias latitude: geoObject.lat
    property alias longitude: geoObject.lon

    property alias timezone: systemService.timezone

    property alias sunrise: solarObject.sunrise
    property alias sunset: solarObject.sunset

    property alias appearance: systemService.appearance
  }

  Process {
    id: solarLookupProc
    stdout: StdioCollector {
      onStreamFinished: () => {
        const [sunriseStr, sunsetStr] = text.trim().split(" ");

        if (!sunriseStr || !sunsetStr) return;

        const [sunriseH, sunriseM] = sunriseStr.split(":").map(s => parseInt(s));
        const [sunsetH, sunsetM] = sunsetStr.split(":").map(s => parseInt(s));

        systemService.solar.sunrise = sunriseH * 60 + sunriseM;
        systemService.solar.sunset = sunsetH * 60 + sunsetM;
      }
    }
  }

  Process {
    id: timezoneLookupProc
    stdout: StdioCollector {
      onStreamFinished: () => {
        const timezoneStr = text.trim();

        if (!timezoneStr) return;

        systemService.timezone = timezoneStr;

        solarLookupProc.exec({
          command: [
            systemService.scriptsDir + "solar-lookup/build",
            "--lat", systemService.geo.lat,
            "--lng", systemService.geo.lon,
            "--tz", systemService.timezone,
            "--date", Qt.formatDate(systemClock.date, "dd/MM/yyyy")
          ]
        })
      }
    }
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

      // No change in location
      if (systemService.geo.lat === coord.latitude &&
          systemService.geo.lon === coord.longitude) {
        return; 
      }

      systemService.geo.lat = coord.latitude;
      systemService.geo.lon = coord.longitude;

      timezoneLookupProc.exec({
        command: [
          systemService.scriptsDir + "tz-lookup/build",
          "--lat", coord.latitude,
          "--lng", coord.longitude
        ]
      })
    }
  }
  
  function shutdown() {
    systemProc.exec(["sh", "-c", "systemctl poweroff"]);
  }

  function restart() {
    systemProc.exec(["sh", "-c", "systemctl reboot"]);
  }

  function sleep() {
    systemProc.exec(["sh", "-c", "systemctl suspend"]);
  }

  Component.onCompleted: {
    positionSource.update();
  }
}