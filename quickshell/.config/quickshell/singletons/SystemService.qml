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

        property double lastTick: 0

        onDateChanged: {
            const now = date.getTime();
            const resumed = lastTick > 0 && now - lastTick > 120000;

            // Waked up from sleep after 2 minutes
            if (resumed) {
                systemService.triggerSolarLookup();
                positionSource.update();
            }

            lastTick = now;
        }
    }

    readonly property string time: Qt.formatTime(systemClock.date, "HH:mm")
    readonly property string date: Qt.formatDate(systemClock.date, "dd/MM/yyyy")

    // LOCATION

    property string timezone: "UTC"

    property double latitude: NaN
    property double longitude: NaN

    Process {
        id: tzLookupProc
        stdout: StdioCollector {
            onStreamFinished: {
                const timezoneStr = text.trim();

                if (!timezoneStr)
                    return;

                if (systemService.timezone !== timezoneStr) {
                    systemService.timezone = timezoneStr;

                    Quickshell.execDetached([systemService.scriptsDir + "change-timezone.sh", timezoneStr]);
                }

                systemService.triggerSolarLookup();
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

            const moved = !isFinite(systemService.latitude) || !isFinite(systemService.longitude) || Math.abs(systemService.latitude - coord.latitude) > 0.01 || Math.abs(systemService.longitude - coord.longitude) > 0.01;

            if (!moved)
                return;

            systemService.latitude = coord.latitude;
            systemService.longitude = coord.longitude;

            tzLookupProc.exec({
                command: [systemService.scriptsDir + "tz-lookup", "--lat", coord.latitude, "--lng", coord.longitude]
            });
        }
    }

    // SOLAR

    property int sunrise: 480 // Default to 8:00
    property int sunset: 1080 // Default to 18:00

    function triggerSolarLookup() {
        if (!isFinite(systemService.latitude) || !isFinite(systemService.longitude))
            return;

        const formattedDate = Qt.formatDate(systemClock.date, "dd/MM/yyyy");

        solarLookupProc.exec({
            command: [systemService.scriptsDir + "solar-lookup", "--lat", systemService.latitude, "--lng", systemService.longitude, "--tz", systemService.timezone, "--date", formattedDate]
        });
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

    // APPEARANCE

    property string appearance: "auto" // "light", "dark", "auto"

    readonly property string theme: {
        if (appearance !== "auto")
            return appearance;

        const minutes = systemClock.hours * 60 + systemClock.minutes;
        return minutes >= sunrise && minutes < sunset ? "light" : "dark";
    }

    onThemeChanged: Qt.callLater(() => {
        Quickshell.execDetached([systemService.scriptsDir + "change-color-theme.sh", theme]);
    })

    // POWER

    function shutdown(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
    function restart(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }
    function sleep(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
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
}
