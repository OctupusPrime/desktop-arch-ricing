pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtCore
import QtPositioning

Singleton {
    id: systemService

    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/scripts/"

    property string appearance: "system"
    property string timezone: "UTC"

    property double latitude: -1
    property double longitude: -1

    property int sunrise: 480 // Default to 8:00
    property int sunset: 1080 // Default to 18:00

    readonly property string time: Qt.formatTime(systemClock.date, "HH:mm")
    readonly property string date: Qt.formatDate(systemClock.date, "dd/MM/yyyy")

    readonly property string theme: {
        if (appearance === "system") {
            const totalMinutes = systemClock.date.getHours() * 60 + systemClock.date.getMinutes();
            const isDaytime = totalMinutes >= systemService.sunrise && totalMinutes < systemService.sunset;
            return isDaytime ? "light" : "dark";
        }
        return appearance;
    }

    Settings {
        category: "System"
        property alias appearance: systemService.appearance
        property alias timezone: systemService.timezone
        property alias latitude: systemService.latitude
        property alias longitude: systemService.longitude
        property alias sunrise: systemService.sunrise
        property alias sunset: systemService.sunset
    }

    onThemeChanged: Qt.callLater(() => {
        themeUpdateProc.exec({
            command: [systemService.scriptsDir + "change-color-theme.sh", theme]
        });
    })

    Component.onCompleted: positionSource.update()

    function shutdown() {
        powerProc.exec(["sh", "-c", "systemctl poweroff"]);
    }
    function restart() {
        powerProc.exec(["sh", "-c", "systemctl reboot"]);
    }
    function sleep() {
        powerProc.exec(["sh", "-c", "systemctl suspend"]);
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    PositionSource {
        id: positionSource
        active: false
        onPositionChanged: {
            const coord = position.coordinate;

            if (!coord.isValid) {
                console.warn("Invalid coordinates received from PositionSource");
                return;
            }

            if (systemService.latitude === coord.latitude && systemService.longitude === coord.longitude)
                return;

            systemService.latitude = coord.latitude;
            systemService.longitude = coord.longitude;

            tzLookupProc.exec({
                command: [systemService.scriptsDir + "tz-lookup/build", "--lat", coord.latitude, "--lng", coord.longitude]
            });
        }
    }

    Process {
        id: themeUpdateProc
    }
    Process {
        id: tzUpdateProc
    }
    Process {
        id: powerProc
    }

    Process {
        id: tzLookupProc
        stdout: StdioCollector {
            onStreamFinished: {
                const timezoneStr = text.trim();
                const formattedDate = Qt.formatDate(systemClock.date, "dd/MM/yyyy");

                if (!timezoneStr)
                    return;

                if (systemService.timezone !== timezoneStr) {
                    tzUpdateProc.exec({
                        command: [systemService.scriptsDir + "change-timezone.sh", timezoneStr]
                    });
                    systemService.timezone = timezoneStr;
                }

                solarLookupProc.exec({
                    command: [systemService.scriptsDir + "solar-lookup/build", "--lat", systemService.latitude, "--lng", systemService.longitude, "--tz", systemService.timezone, "--date", formattedDate]
                });
            }
        }
    }

    Process {
        id: solarLookupProc
        stdout: StdioCollector {
            onStreamFinished: {
                const [sunriseStr, sunsetStr] = text.trim().split(" ");

                if (!sunriseStr || !sunsetStr)
                    return;

                const [sunriseH, sunriseM] = sunriseStr.split(":").map(s => parseInt(s));
                const [sunsetH, sunsetM] = sunsetStr.split(":").map(s => parseInt(s));

                systemService.sunrise = sunriseH * 60 + sunriseM;
                systemService.sunset = sunsetH * 60 + sunsetM;
            }
        }
    }
}
