pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

// TODO create a custor script in go to controll auto brightness based on ambient light sensor and expose it via ipc, since ddcutil doesn't support it
Singleton {
    id: monitorService

    property list<var> ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances

    Variants {
        id: variants
        model: Quickshell.screens

        Monitor {}
    }

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Process {
        id: ddcProc

        command: ["ddcutil", "detect", "--brief"]
        stdout: StdioCollector {
            onStreamFinished: monitorService.ddcMonitors = text.trim().split("\n\n").filter(d => d.startsWith("Display ")).map(d => ({
                        busNum: d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/)[1],
                        connector: d.match(/DRM connector:\s+(.*)/)[1].replace(/^card\d+-/, "") // strip "card1-"
                    }))
        }
    }

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.modelData === screen);
    }

    function getMonitor(query: string): var {
        if (query === "active") {
            return monitors.find(m => Hyprland.monitorFor(m.modelData)?.focused);
        }

        if (query.startsWith("model:")) {
            const model = query.slice(6);
            return monitors.find(m => m.modelData.model === model);
        }

        if (query.startsWith("serial:")) {
            const serial = query.slice(7);
            return monitors.find(m => m.modelData.serialNumber === serial);
        }

        if (query.startsWith("id:")) {
            const id = parseInt(query.slice(3), 10);
            return monitors.find(m => Hyprland.monitorFor(m.modelData)?.id === id);
        }

        return monitors.find(m => m.modelData.name === query);
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: monitorService.ddcMonitors.some(m => m.connector === modelData.name)
        readonly property string busNum: monitorService.ddcMonitors.find(m => m.connector === modelData.name)?.busNum ?? ""

        property real brightness
        property real queuedBrightness: NaN

        readonly property Process initProc: Process {
            stdout: StdioCollector {
                onStreamFinished: {
                    const [, , , cur, max] = text.split(" ");
                    monitor.brightness = parseInt(cur) / parseInt(max);
                }
            }
        }

        readonly property Timer timer: Timer {
            interval: 500
            onTriggered: {
                if (!isNaN(monitor.queuedBrightness)) {
                    monitor.setBrightness(monitor.queuedBrightness);
                    monitor.queuedBrightness = NaN;
                }
            }
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            const rounded = Math.round(value * 100);
            if (Math.round(brightness * 100) === rounded)
                return;

            if (isDdc && timer.running) {
                queuedBrightness = value;
                return;
            }

            brightness = value;

            if (isDdc)
                Quickshell.execDetached(["ddcutil", "-b", busNum, "setvcp", "10", rounded]);
            else
                Quickshell.execDetached(["brightnessctl", "s", `${rounded}%`]);

            if (isDdc)
                timer.restart();
        }

        function initBrightness(): void {
            if (isDdc)
                initProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"];
            else
                initProc.command = ["sh", "-c", "echo a b c $(brightnessctl g) $(brightnessctl m)"];

            initProc.running = true;
        }

        onBusNumChanged: initBrightness()
        Component.onCompleted: initBrightness()
    }

    IpcHandler {
        target: "brightness"

        function get(): real {
            return getFor("active");
        }

        // Allows searching by active/model/serial/id/name
        function getFor(query: string): real {
            return monitorService.getMonitor(query)?.brightness ?? -1;
        }

        function set(value: string): string {
            return setFor("active", value);
        }

        // Handles brightness value like brightnessctl: 0.1, +0.1, 0.1-, 10%, +10%, 10%-
        function setFor(query: string, value: string): string {
            const monitor = monitorService.getMonitor(query);
            if (!monitor)
                return "Invalid monitor: " + query;

            let targetBrightness;
            if (value.endsWith("%-")) {
                const percent = parseFloat(value.slice(0, -2));
                targetBrightness = monitor.brightness - (percent / 100);
            } else if (value.startsWith("+") && value.endsWith("%")) {
                const percent = parseFloat(value.slice(1, -1));
                targetBrightness = monitor.brightness + (percent / 100);
            } else if (value.endsWith("%")) {
                const percent = parseFloat(value.slice(0, -1));
                targetBrightness = percent / 100;
            } else if (value.startsWith("+")) {
                const increment = parseFloat(value.slice(1));
                targetBrightness = monitor.brightness + increment;
            } else if (value.endsWith("-")) {
                const decrement = parseFloat(value.slice(0, -1));
                targetBrightness = monitor.brightness - decrement;
            } else if (value.includes("%") || value.includes("-") || value.includes("+")) {
                return `Invalid brightness format: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;
            } else {
                targetBrightness = parseFloat(value);
            }

            if (isNaN(targetBrightness))
                return `Failed to parse value: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;

            monitor.setBrightness(targetBrightness);

            return `Set monitor ${monitor.modelData.name} brightness to ${+monitor.brightness.toFixed(2)}`;
        }
    }

    property bool nightShiftEnabled: false

    function enableNightShift(): void {
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", "4000"]);
        nightShiftEnabled = true;
    }

    function disableNightShift(): void {
        Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
        nightShiftEnabled = false;
    }

    function toggleNightShift(): void {
        if (nightShiftEnabled)
            disableNightShift();
        else
            enableNightShift();
    }
}
