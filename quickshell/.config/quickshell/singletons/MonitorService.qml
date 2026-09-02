pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: monitorService

    // DDC
    property var ddcMonitors: []

    Process {
        id: ddcProc

        command: ["ddcutil", "detect", "--brief"]

        stdout: StdioCollector {
            onStreamFinished: {
                const monitors = [];

                for (const block of text.trim().split("\n\n")) {
                    if (!block.startsWith("Display "))
                        continue;

                    const bus = block.match(/I2C bus:\s*\/dev\/i2c-(\d+)/);
                    const connector = block.match(/DRM connector:\s*(.+)/);

                    if (!bus || !connector)
                        continue;

                    monitors.push({
                        busNum: bus[1],
                        connector: connector[1].replace(/^card\d+-/, "")
                    });
                }

                monitorService.ddcMonitors = monitors;
            }
        }
    }

    // MONITORS
    readonly property list<Monitor> monitors: monitorVariants.instances

    Variants {
        id: monitorVariants

        model: Quickshell.screens

        Monitor {}
    }

    onMonitorsChanged: {
        monitorService.ddcMonitors = [];
        ddcProc.running = true;
    }

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(monitor => monitor.modelData === screen);
    }

    function getMonitor(query: string): var {
        if (query === "active")
            return monitors.find(monitor => Hyprland.monitorFor(monitor.modelData)?.focused);

        if (query.startsWith("model:")) {
            const model = query.slice(6);
            return monitors.find(monitor => monitor.modelData.model === model);
        }

        if (query.startsWith("serial:")) {
            const serial = query.slice(7);
            return monitors.find(monitor => monitor.modelData.serialNumber === serial);
        }

        if (query.startsWith("id:")) {
            const id = parseInt(query.slice(3), 10);
            return monitors.find(monitor => Hyprland.monitorFor(monitor.modelData)?.id === id);
        }

        return monitors.find(monitor => monitor.modelData.name === query);
    }

    // MONITOR
    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData

        readonly property var ddc: monitorService.ddcMonitors.find(ddc => ddc.connector === modelData.name)

        readonly property bool isDdc: ddc !== undefined
        readonly property string busNum: ddc?.busNum ?? ""

        property real brightness: 0
        property real queuedBrightness: NaN

        // BRIGHTNESS INITIALIZATION
        readonly property Process brightnessProc: Process {
            stdout: StdioCollector {
                onStreamFinished: {
                    const values = text.trim().split(/\s+/);
                    const current = parseInt(values[3]);
                    const maximum = parseInt(values[4]);

                    if (maximum > 0)
                        monitor.brightness = current / maximum;
                }
            }
        }

        function initBrightness(): void {
            if (isDdc) {
                brightnessProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"];
            } else {
                brightnessProc.command = ["sh", "-c", "echo a b c $(brightnessctl g) $(brightnessctl m)"];
            }

            brightnessProc.running = true;
        }

        onBusNumChanged: initBrightness()
        Component.onCompleted: initBrightness()

        // BRIGHTNESS CONTROL
        readonly property Timer ddcTimer: Timer {
            interval: 500

            onTriggered: {
                if (isNaN(monitor.queuedBrightness))
                    return;

                const brightness = monitor.queuedBrightness;

                monitor.queuedBrightness = NaN;
                monitor.setBrightness(brightness);
            }
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));

            const percent = Math.round(value * 100);

            if (Math.round(brightness * 100) === percent)
                return;

            if (isDdc && ddcTimer.running) {
                queuedBrightness = value;
                return;
            }

            brightness = value;

            if (isDdc) {
                Quickshell.execDetached(["ddcutil", "-b", busNum, "setvcp", "10", percent]);

                ddcTimer.restart();
            } else {
                Quickshell.execDetached(["brightnessctl", "s", `${percent}%`]);
            }
        }
    }

    // BRIGHTNESS IPC
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
                return `Invalid monitor: ${query}`;

            let brightness;

            if (value.endsWith("%-"))
                brightness = monitor.brightness - parseFloat(value) / 100;
            else if (value.startsWith("+") && value.endsWith("%"))
                brightness = monitor.brightness + parseFloat(value) / 100;
            else if (value.endsWith("%"))
                brightness = parseFloat(value) / 100;
            else if (value.startsWith("+"))
                brightness = monitor.brightness + parseFloat(value);
            else if (value.endsWith("-"))
                brightness = monitor.brightness - parseFloat(value);
            else if (/[+%-]/.test(value))
                return `Invalid brightness format: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;
            else
                brightness = parseFloat(value);

            if (isNaN(brightness))
                return `Failed to parse value: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;

            monitor.setBrightness(brightness);

            return `Set monitor ${monitor.modelData.name} brightness to ${+monitor.brightness.toFixed(2)}`;
        }
    }

    // NIGHT SHIFT
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
