pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

Singleton {
    id: pipewireService

    readonly property var nodes: Pipewire.nodes.values.reduce((nodes, node) => {
        if (node.isStream)
            return nodes;

        if ((node.type & PwNodeType.AudioSink) === PwNodeType.AudioSink)
            nodes.sinks.push(node);
        if ((node.type & PwNodeType.AudioSource) === PwNodeType.AudioSource)
            nodes.sources.push(node);
        if ((node.type & PwNodeType.VideoSource) === PwNodeType.VideoSource)
            nodes.cameras.push(node);

        return nodes;
    }, {
        sinks: [],
        sources: [],
        cameras: []
    })

    function deviceName(device): string {
        return device?.nickname || device?.description || device?.name || "Unknown device";
    }

    function hasActiveSourceLink(devices: list<PwNode>): bool {
        return Pipewire.linkGroups.values.some(group => {
            if (group.state !== PwLinkState.Active || !group.source)
                return false;

            return devices.some(device => device.id === group.source.id);
        });
    }

    // SINKS

    readonly property list<PwNode> sinks: nodes.sinks
    readonly property PwNode sink: Pipewire.defaultAudioSink

    readonly property real sinkVolume: sink?.audio?.volume ?? 0
    readonly property bool sinkMuted: sink?.audio?.muted ?? false

    function setSinkVolume(volume: real): void {
        if (sink?.ready && sink.audio)
            sink.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function incrementSinkVolume(amount = 0.1): void {
        setSinkVolume(sinkVolume + amount);
    }

    function decrementSinkVolume(amount = 0.1): void {
        setSinkVolume(sinkVolume - amount);
    }

    function setSinkMuted(muted: bool): void {
        if (sink?.ready && sink.audio)
            sink.audio.muted = muted;
    }

    function setAudioSink(node: PwNode): void {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    // SOURCES

    readonly property list<PwNode> sources: nodes.sources
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: source?.audio?.muted ?? false

    function setSourceVolume(volume: real): void {
        if (source?.ready && source.audio)
            source.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function incrementSourceVolume(amount = 0.1): void {
        setSourceVolume(sourceVolume + amount);
    }

    function decrementSourceVolume(amount = 0.1): void {
        setSourceVolume(sourceVolume - amount);
    }

    function setSourceMuted(muted: bool): void {
        if (source?.ready && source.audio)
            source.audio.muted = muted;
    }

    function setAudioSource(node: PwNode): void {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    // MICROPHONE PRIVACY

    readonly property bool microphoneEnabled: sources.some(node => !node.audio?.muted)

    readonly property bool microphoneInUse: hasActiveSourceLink(sources)

    function setMicrophoneEnabled(enabled: bool): void {
        for (const node of sources) {
            if (node.ready && node.audio)
                node.audio.muted = !enabled;
        }
    }

    function toggleMicrophoneEnabled(): void {
        setMicrophoneEnabled(!microphoneEnabled);
    }

    // CAMERAS

    readonly property list<PwNode> cameras: nodes.cameras
    readonly property PwNode camera: cameras[0] ?? null

    readonly property bool cameraSupported: cameras.length > 0

    // CAMERA PRIVACY

    property bool cameraEnabled: true

    readonly property bool cameraInUse: hasActiveSourceLink(cameras)

    function setCameraEnabled(enabled: bool): void {
        if (cameraEnabled === enabled)
            return;

        cameraEnabled = enabled;

        cameraPrivacyProc.exec(["wpctl", "settings", "privacy.camera-enabled", enabled ? "true" : "false"]);
    }

    function toggleCameraEnabled(): void {
        setCameraEnabled(!cameraEnabled);
    }

    Process {
        id: cameraPrivacyProc
    }

    // TRACKING
    PwObjectTracker {
        objects: pipewireService.sinks.concat(pipewireService.sources).concat(pipewireService.cameras).concat(Pipewire.linkGroups.values)
    }
}
