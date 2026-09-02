pragma Singleton

import Quickshell.Bluetooth
import Quickshell
import QtQuick

Singleton {
    id: bluetoothService

    readonly property var adapter: Bluetooth.defaultAdapter

    function deviceKey(device): string {
        return device?.dbusPath || device?.address || "";
    }

    function displayName(device): string {
        return device?.name || device?.deviceName || device?.address || "Unknown device";
    }

    // ADAPTER

    readonly property bool supported: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false

    function setEnabled(enabled: bool): void {
        if (!bluetoothService.adapter)
            return;

        if (!enabled)
            bluetoothService.setDiscovering(false);

        bluetoothService.adapter.enabled = enabled;
    }

    function setDiscovering(discovering: bool): void {
        if (bluetoothService.adapter && bluetoothService.enabled)
            bluetoothService.adapter.discovering = discovering;
    }

    // DEVICES

    readonly property var devices: {
        if (!adapter)
            return [];

        return adapter.devices.values.slice().sort((a, b) => b.connected - a.connected || b.paired - a.paired || bluetoothService.displayName(a).localeCompare(bluetoothService.displayName(b)));
    }

    readonly property var connectedDevices: devices.filter(device => device.connected)
    readonly property bool connected: connectedDevices.length > 0

    function connectDevice(device): void {
        if (!device || device.connected || device.state !== BluetoothDeviceState.Disconnected)
            return;

        bluetoothService.clearConnectionError(device);

        if (!bluetoothService.enabled) {
            bluetoothService.setConnectionError(device, "Bluetooth is disabled.");
            return;
        }

        if (device.adapter !== bluetoothService.adapter) {
            bluetoothService.setConnectionError(device, "Device is unavailable.");
            return;
        }

        if (!device.paired) {
            bluetoothService.setConnectionError(device, "Pair the device first.");
            return;
        }

        if (device.blocked) {
            bluetoothService.setConnectionError(device, "Device is blocked.");
            return;
        }

        device.connect();
    }

    function disconnectDevice(device): void {
        if (!device)
            return;

        bluetoothService.clearConnectionError(device);

        if (device.state === BluetoothDeviceState.Connected || device.state === BluetoothDeviceState.Connecting) {
            device.disconnect();
        }
    }

    // ERRORS

    property var connectionErrors: ({})

    function updateError(map, key, message): var {
        const next = Object.assign({}, map);

        if (message === null)
            delete next[key];
        else
            next[key] = message;

        return next;
    }

    function connectionError(device) {
        return bluetoothService.connectionErrors[bluetoothService.deviceKey(device)] ?? null;
    }

    function setConnectionError(device, message: string): void {
        bluetoothService.connectionErrors = bluetoothService.updateError(bluetoothService.connectionErrors, bluetoothService.deviceKey(device), message);
    }

    function clearConnectionError(device): void {
        bluetoothService.connectionErrors = bluetoothService.updateError(bluetoothService.connectionErrors, bluetoothService.deviceKey(device), null);
    }

    // DEVICE MONITORING

    property Instantiator deviceWatchers: Instantiator {
        model: bluetoothService.adapter?.devices ?? null

        delegate: Connections {
            required property var modelData
            property bool wasConnecting: false

            target: modelData

            function onPairedChanged(): void {
                bluetoothService.clearConnectionError(modelData);
            }

            function onConnectedChanged(): void {
                if (!modelData.connected)
                    return;

                wasConnecting = false;
                bluetoothService.clearConnectionError(modelData);
            }

            function onStateChanged(): void {
                if (modelData.state === BluetoothDeviceState.Connecting) {
                    wasConnecting = true;
                    return;
                }

                if (modelData.state === BluetoothDeviceState.Connected) {
                    wasConnecting = false;
                    bluetoothService.clearConnectionError(modelData);
                    return;
                }

                if (modelData.state === BluetoothDeviceState.Disconnecting) {
                    wasConnecting = false;
                    return;
                }

                if (modelData.state !== BluetoothDeviceState.Disconnected || !wasConnecting)
                    return;

                wasConnecting = false;

                if (bluetoothService.enabled)
                    bluetoothService.setConnectionError(modelData, "Connection failed.");
                else
                    bluetoothService.clearConnectionError(modelData);
            }
        }
    }
}
