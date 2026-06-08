pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

// TODO check if cameras are working enable disable working, need a real camera to test
Singleton {
    id: mediaService

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (node.isStream)
            return acc;

        if (node.isSink)
            acc.sinks.push(node);
        else if (node.audio)
            acc.sources.push(node);
        else if (node.video)
            acc.videos.push(node);

        return acc;
    }, {
        sources: [],
        sinks: [],
        videos: []
    })

    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources
    readonly property list<PwNode> videos: nodes.videos

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property PwNode video: {
        const preferred = nodes.videos.find(n => !n.name.includes("dummy"));
        return preferred ?? nodes.videos[0] ?? null;
    }

    readonly property bool sinkMuted: !!sink?.audio?.muted
    readonly property real sinkVolume: sink?.audio?.volume ?? 0

    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: !!source?.audio?.muted
    property bool videoMuted: false

    function setSinkVolume(newVolume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }
    function incrementSinkVolume(amount: real): void {
        setSinkVolume(sinkVolume + (amount || 0.1));
    }
    function decrementSinkVolume(amount: real): void {
        setSinkVolume(sinkVolume - (amount || 0.1));
    }

    function setSourceVolume(newVolume: real): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }
    function incrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume + (amount || 0.1));
    }
    function decrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume - (amount || 0.1));
    }

    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function muteSource(): void {
        if (source?.ready && source?.audio)
            source.audio.muted = true;
    }
    function unmuteSource(): void {
        if (source?.ready && source?.audio)
            source.audio.muted = false;
    }
    function toggleSourceMute(): void {
        if (sourceMuted)
            unmuteSource();
        else
            muteSource();
    }

    Process {
        id: videoPermissionCmd
    }

    function muteVideo(): void {
        if (!video)
            return;

        videoPermissionCmd.command = ["pw-cli", "s", video.id.toString(), "Permissions", "0"];
        videoPermissionCmd.running = true;

        videoMuted = true;
    }
    function unmuteVideo(): void {
        if (!video)
            return;

        videoPermissionCmd.command = ["pw-cli", "s", video.id.toString(), "Permissions", "0x7"];
        videoPermissionCmd.running = true;

        videoMuted = false;
    }
    function toggleVideoMute(): void {
        if (videoMuted)
            unmuteVideo();
        else
            muteVideo();
    }

    PwObjectTracker {
        objects: [...mediaService.sinks, ...mediaService.sources, ...mediaService.videos]
    }
}
