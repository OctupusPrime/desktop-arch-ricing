pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// TODO check if cameras are working
// TODO add support to enable/disable cameras (need a real camera to test)
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
    readonly property PwNode video: nodes.videos.length > 0 ? nodes.videos[0] : null

    readonly property bool sinkMuted: !!sink?.audio?.muted
    readonly property real sinkVolume: sink?.audio?.volume ?? 0

    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: !!source?.audio?.muted

    readonly property string sinkIcon: {
        if (sinkMuted || sinkVolume === 0)
            return "root:/assets/icons/volume-x.svg";
        if (sinkVolume < 0.33)
            return "root:/assets/icons/volume.svg";
        if (sinkVolume < 0.66)
            return "root:/assets/icons/volume-1.svg";
        return "root:/assets/icons/volume-2.svg";
    }
    readonly property string sourceIcon: {
        if (sourceMuted || sourceVolume === 0)
            return "root:/assets/icons/mic-off.svg";
        return "root:/assets/icons/mic.svg";
    }
    readonly property string videoIcon: "root:/assets/icons/video.svg"

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

    function enableVideoSource(): void {
        console.log('TODO: Enable video source');
    }

    function disableVideoSource(): void {
        console.log('TODO: Disable video source');
    }

    PwObjectTracker {
        objects: [...mediaService.sinks, ...mediaService.sources, ...mediaService.videos]
    }
}
