pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Singleton {
    id: bluetoothAgent

    readonly property var adapter: Bluetooth.defaultAdapter

    function deviceKey(device): string {
        return device?.dbusPath || device?.address || "";
    }

    // Current device being paired.
    property var pairingDevice: null
    readonly property bool pairing: bluetoothAgent.pairingDevice !== null

    // Current authentication request:
    // pin, passkey, confirm, authorize, display
    property var request: null

    readonly property bool active: bluetoothAgent.request !== null
    readonly property bool inputRequired: bluetoothAgent.active && bluetoothAgent.request.type !== "display"
    readonly property bool available: bluetoothAgent.pairingDevice === null && !agent.running

    property string outputBuffer: ""

    // ADAPTER

    onAdapterChanged: {
        if (bluetoothAgent.pairingDevice && bluetoothAgent.pairingDevice.adapter !== bluetoothAgent.adapter)
            bluetoothAgent.cancelPairing();
    }

    onPairingDeviceChanged: {
        if (bluetoothAgent.pairingDevice)
            return;

        agentTimer.stop();
        pairingTimer.stop();
        bluetoothAgent.request = null;
        bluetoothAgent.outputBuffer = "";
    }

    Connections {
        target: bluetoothAgent.adapter

        function onEnabledChanged(): void {
            if (!bluetoothAgent.adapter?.enabled)
                bluetoothAgent.cancelPairing();
        }
    }

    Connections {
        target: bluetoothAgent.pairingDevice

        function onPairedChanged(): void {
            const device = bluetoothAgent.pairingDevice;

            if (!device?.paired)
                return;

            device.trusted = true;
            bluetoothAgent.finishPairing(device);
        }

        function onPairingChanged(): void {
            const device = bluetoothAgent.pairingDevice;

            if (!device)
                return;

            if (device.pairing) {
                pairingTimer.stop();
                return;
            }

            // BlueZ may publish Pairing=false just before Paired=true.
            Qt.callLater(() => {
                if (device && !device.pairing && !device.paired && bluetoothAgent.pairingDevice === device) {
                    bluetoothAgent.finishPairing(device, "Pairing failed.");
                }
            });
        }
    }

    // PAIRING

    function startPairing(device): void {
        if (!device || device.paired || device.pairing)
            return;

        bluetoothAgent.clearPairingError(device);

        if (!bluetoothAgent.adapter?.enabled) {
            bluetoothAgent.setPairingError(device, "Bluetooth is disabled.");
            return;
        }

        if (device.adapter !== bluetoothAgent.adapter) {
            bluetoothAgent.setPairingError(device, "Device is unavailable.");
            return;
        }

        if (device.blocked) {
            bluetoothAgent.setPairingError(device, "Device is blocked.");
            return;
        }

        if (bluetoothAgent.pairing) {
            bluetoothAgent.setPairingError(device, "Another device is being paired.");
            return;
        }

        if (!bluetoothAgent.available) {
            bluetoothAgent.setPairingError(device, "Pairing agent is busy.");
            return;
        }

        bluetoothAgent.request = null;
        bluetoothAgent.outputBuffer = "";
        bluetoothAgent.pairingDevice = device;
        agentTimer.restart();
    }

    function finishPairing(device, error = null): void {
        if (!device || bluetoothAgent.pairingDevice !== device)
            return;

        agentTimer.stop();
        pairingTimer.stop();
        bluetoothAgent.request = null;
        bluetoothAgent.outputBuffer = "";
        bluetoothAgent.pairingDevice = null;

        if (error)
            bluetoothAgent.setPairingError(device, error);
        else
            bluetoothAgent.clearPairingError(device);
    }

    function cancelPairing(device = bluetoothAgent.pairingDevice): void {
        if (!device || bluetoothAgent.pairingDevice !== device)
            return;

        if (device.pairing)
            device.cancelPair();

        bluetoothAgent.finishPairing(device);
    }

    function failPairing(message: string): void {
        const device = bluetoothAgent.pairingDevice;

        if (!device)
            return;

        if (device.pairing)
            device.cancelPair();

        bluetoothAgent.finishPairing(device, message);
    }

    Timer {
        id: agentTimer
        interval: 10000

        onTriggered: bluetoothAgent.failPairing("Bluetooth pairing agent did not start.")
    }

    Timer {
        id: pairingTimer
        interval: 10000

        onTriggered: {
            const device = bluetoothAgent.pairingDevice;

            if (device && !device.pairing && !device.paired)
                bluetoothAgent.finishPairing(device, "Pairing failed to start.");
        }
    }

    // RESPONSE

    function submitRequest(value): bool {
        const type = bluetoothAgent.request?.type;
        let answer = null;

        if (type === "pin") {
            if (typeof value !== "string" || !value || value.length > 16 || /[\r\n]/.test(value))
                return false;

            answer = value;
        } else if (type === "passkey") {
            if (typeof value !== "string" || !/^\d{1,6}$/.test(value) || Number(value) > 999999)
                return false;

            answer = value;
        } else if (type === "confirm" || type === "authorize") {
            if (typeof value !== "boolean")
                return false;

            answer = value ? "yes" : "no";
        } else {
            return false;
        }

        if (!agent.running)
            return false;

        agent.write(answer + "\n");
        bluetoothAgent.request = null;
        bluetoothAgent.outputBuffer = "";
        return true;
    }

    // ERRORS

    property var pairingErrors: ({})

    function updateError(map, key, message): var {
        const next = Object.assign({}, map);

        if (message === null)
            delete next[key];
        else
            next[key] = message;

        return next;
    }

    function pairingError(device) {
        return bluetoothAgent.pairingErrors[bluetoothAgent.deviceKey(device)] ?? null;
    }

    function setPairingError(device, message: string): void {
        bluetoothAgent.pairingErrors = bluetoothAgent.updateError(bluetoothAgent.pairingErrors, bluetoothAgent.deviceKey(device), message);
    }

    function clearPairingError(device): void {
        bluetoothAgent.pairingErrors = bluetoothAgent.updateError(bluetoothAgent.pairingErrors, bluetoothAgent.deviceKey(device), null);
    }

    // BLUEZ AGENT

    function setAgentRequest(type: string, passkey = null): void {
        bluetoothAgent.request = {
            type: type,
            device: bluetoothAgent.pairingDevice,
            passkey: passkey
        };
        bluetoothAgent.outputBuffer = "";
    }

    function handleAgentOutput(chunk: string): void {
        if (!bluetoothAgent.pairingDevice)
            return;

        const clean = chunk.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "").replace(/\r/g, "\n");
        bluetoothAgent.outputBuffer = (bluetoothAgent.outputBuffer + clean).slice(-4096);

        const text = bluetoothAgent.outputBuffer;

        if (/Failed to register agent|Failed to request default agent/i.test(text)) {
            bluetoothAgent.failPairing("Failed to start Bluetooth pairing agent.");
            return;
        }

        if (/Agent registered/i.test(text)) {
            bluetoothAgent.outputBuffer = "";

            if (agent.running)
                agent.write("default-agent\n");

            return;
        }

        if (/Default agent request successful/i.test(text)) {
            const device = bluetoothAgent.pairingDevice;

            agentTimer.stop();
            bluetoothAgent.outputBuffer = "";

            if (device) {
                device.pair();
                pairingTimer.restart();
            }

            return;
        }

        if (/Request canceled/i.test(text)) {
            bluetoothAgent.request = null;
            bluetoothAgent.outputBuffer = "";
            return;
        }

        let match = text.match(/Confirm passkey\s+(\d+)/i);

        if (match) {
            bluetoothAgent.setAgentRequest("confirm", match[1]);
            return;
        }

        if (/Enter PIN code/i.test(text)) {
            bluetoothAgent.setAgentRequest("pin");
            return;
        }

        if (/Enter passkey/i.test(text)) {
            bluetoothAgent.setAgentRequest("passkey");
            return;
        }

        if (/Authorize service|Request authorization/i.test(text)) {
            bluetoothAgent.setAgentRequest("authorize");
            return;
        }

        match = text.match(/PIN code:\s*(\S+)/i);

        if (match) {
            bluetoothAgent.setAgentRequest("display", match[1]);
            return;
        }

        match = text.match(/Passkey:\s*(\d+)/i);

        if (match)
            bluetoothAgent.setAgentRequest("display", match[1]);
    }

    property Process agent: Process {
        running: bluetoothAgent.pairing
        stdinEnabled: true
        command: ["bluetoothctl", "--agent", "KeyboardDisplay"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: chunk => bluetoothAgent.handleAgentOutput(chunk)
        }

        stderr: SplitParser {
            splitMarker: ""
            onRead: chunk => bluetoothAgent.handleAgentOutput(chunk)
        }

        onExited: {
            if (bluetoothAgent.pairing)
                bluetoothAgent.failPairing("Bluetooth pairing agent exited.");
        }
    }
}
