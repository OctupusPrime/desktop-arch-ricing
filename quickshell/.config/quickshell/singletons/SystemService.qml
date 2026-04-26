pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtCore
import QtPositioning

Singleton {
    id: systemService

    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/scripts/"

    // TIME

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    readonly property string time: Qt.formatTime(systemClock.date, "HH:mm")
    readonly property string date: Qt.formatDate(systemClock.date, "dd/MM/yyyy")

    // LOCATION

    property string timezone: "UTC"

    property double latitude: NaN
    property double longitude: NaN

    property int sunrise: 480 // Default to 8:00
    property int sunset: 1080 // Default to 18:00

    function triggerSolarLookup() {
        if (!isFinite(systemService.latitude) || !isFinite(systemService.longitude))
            return;

        const formattedDate = Qt.formatDate(systemClock.date, "dd/MM/yyyy");

        solarLookupProc.exec({
            command: [systemService.scriptsDir + "solar-lookup/build", "--lat", systemService.latitude, "--lng", systemService.longitude, "--tz", systemService.timezone, "--date", formattedDate]
        });
    }

    Process {
        id: tzLookupProc
        stdout: StdioCollector {
            onStreamFinished: {
                const timezoneStr = text.trim();

                if (!timezoneStr)
                    return;

                if (systemService.timezone !== timezoneStr) {
                    tzUpdateProc.exec({
                        command: [systemService.scriptsDir + "change-timezone.sh", timezoneStr]
                    });
                    systemService.timezone = timezoneStr;
                }

                systemService.triggerSolarLookup();
            }
        }
    }

    Process {
        id: tzUpdateProc
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

    // APPEARANCE

    property string appearance: "auto" // "light", "dark", "auto"

    readonly property string theme: {
        if (appearance === "auto") {
            const totalMinutes = systemClock.date.getHours() * 60 + systemClock.date.getMinutes();
            const isDaytime = totalMinutes >= systemService.sunrise && totalMinutes < systemService.sunset;
            return isDaytime ? "light" : "dark";
        }
        return appearance;
    }

    onThemeChanged: Qt.callLater(() => {
        themeUpdateProc.exec({
            command: [systemService.scriptsDir + "change-color-theme.sh", theme]
        });
    })

    Process {
        id: themeUpdateProc
    }

    // POWER

    function shutdown() {
        powerProc.exec(["/usr/bin/sh", "-c", "/usr/bin/systemctl poweroff"]);
    }
    function restart() {
        powerProc.exec(["/usr/bin/sh", "-c", "/usr/bin/systemctl reboot"]);
    }
    function sleep() {
        powerProc.exec(["/usr/bin/sh", "-c", "/usr/bin/systemctl suspend"]);
    }

    Process {
        id: powerProc
    }

    // GENERAL

    Settings {
        category: "System"
        property alias timezone: systemService.timezone
        property alias latitude: systemService.latitude
        property alias longitude: systemService.longitude
        property alias sunrise: systemService.sunrise
        property alias sunset: systemService.sunset
        property alias appearance: systemService.appearance
    }

    Component.onCompleted: {
        systemService.triggerSolarLookup();
        positionSource.update();
    }

    Process {
        id: sleepMonitor
        running: true
        command: ["dbus-monitor", "--system", "type='signal',sender='org.freedesktop.login1',member='PrepareForSleep'"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "boolean false")
                    return;

                systemService.triggerSolarLookup();
                positionSource.update();
            }
        }
    }
}
