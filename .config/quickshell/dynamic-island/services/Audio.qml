import Quickshell
import Quickshell.Services.Pipewire

Singleton {
	id: audio

	property PwNode sink: Pipewire.defaultAudioSink

	readonly property real volume: boundSink?.audio?.volume ?? 0.0
	readonly property bool muted: boundSink?.audio?.muted ?? false
	readonly property int volumePercent: Math.round(volume * 100)
	readonly property string sinkName: sink?.description ?? ""

	property PwNode boundSink: sink

	PwObjectTracker {
		objects: [audio.boundSink]
	}

	onSinkChanged: function(newSink) {
		boundSink = newSink
	}

	function setVolume(v) {
		if (boundSink?.audio) boundSink.audio.volume = v
	}

	function toggleMute() {
		if (boundSink?.audio) boundSink.audio.muted = !boundSink.audio.muted
	}
}
