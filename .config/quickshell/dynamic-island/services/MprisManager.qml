pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
	readonly property var players: Mpris.players
	readonly property var activePlayer: players.length > 0 ? players[0] : null
	readonly property bool hasPlayer: activePlayer !== null
	readonly property bool isPlaying: hasPlayer && activePlayer.playbackState === MprisPlaybackState.Playing
	readonly property bool isPaused: hasPlayer && activePlayer.playbackState === MprisPlaybackState.Paused

	readonly property string trackTitle: hasPlayer ? activePlayer.trackTitle : ""
	readonly property string artist: hasPlayer ? activePlayer.artist : ""
	readonly property string album: hasPlayer ? activePlayer.album : ""
	readonly property url artUrl: hasPlayer ? activePlayer.artUrl : ""
	readonly property string playerName: hasPlayer ? activePlayer.playerName : ""
	readonly property real trackLength: hasPlayer ? activePlayer.length : 0
	readonly property real position: hasPlayer ? activePlayer.position : 0
}
