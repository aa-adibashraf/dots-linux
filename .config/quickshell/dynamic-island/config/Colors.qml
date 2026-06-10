pragma Singleton
import Quickshell
import Quickshell.Io
import QtQml

Singleton {
	property var values: ({})

	FileView {
		id: schemeFile
		path: Quickshell.env("HOME") + "/.config/hypr/scheme/current.conf"
		watchChanges: true
		onFileChanged: Colors.parseScheme(text())
	}

	Component.onCompleted: {
		var text = schemeFile.text()
		if (text) Colors.parseScheme(text)
	}

	function parseScheme(text) {
		var map = {}
		var lines = text.split('\n')
		for (var i = 0; i < lines.length; i++) {
			var line = lines[i].trim()
			if (line.charAt(0) === '$' && line.indexOf('=') > -1) {
				var eqPos = line.indexOf('=')
				var name = line.substring(1, eqPos).trim()
				var value = line.substring(eqPos + 1).trim()
				if (/^[0-9a-fA-F]{6}$/.test(value)) {
					map[name] = "#" + value
				}
			}
		}
		values = map
	}

	readonly property string background: values["background"] || "#131317"
	readonly property string onBackground: values["onBackground"] || "#e4e1e7"
	readonly property string surface: values["surface"] || "#131317"
	readonly property string onSurface: values["onSurface"] || "#e4e1e7"
	readonly property string surfaceVariant: values["surfaceVariant"] || "#46464f"
	readonly property string onSurfaceVariant: values["onSurfaceVariant"] || "#c6c5d1"
	readonly property string primary: values["primary"] || "#bac3ff"
	readonly property string onPrimary: values["onPrimary"] || "#232c60"
	readonly property string primaryContainer: values["primaryContainer"] || "#6a73ac"
	readonly property string onPrimaryContainer: values["onPrimaryContainer"] || "#ffffff"
	readonly property string secondary: values["secondary"] || "#c3c5e0"
	readonly property string onSecondary: values["onSecondary"] || "#2c2f44"
	readonly property string secondaryContainer: values["secondaryContainer"] || "#42455c"
	readonly property string onSecondaryContainer: values["onSecondaryContainer"] || "#b1b3ce"
	readonly property string tertiary: values["tertiary"] || "#f1b3e5"
	readonly property string onTertiary: values["onTertiary"] || "#4c1f48"
	readonly property string tertiaryContainer: values["tertiaryContainer"] || "#b77ead"
	readonly property string onTertiaryContainer: values["onTertiaryContainer"] || "#000000"
	readonly property string error: values["error"] || "#ffb4ab"
	readonly property string onError: values["onError"] || "#690005"
	readonly property string errorContainer: values["errorContainer"] || "#93000a"
	readonly property string onErrorContainer: values["onErrorContainer"] || "#ffdad6"
	readonly property string outline: values["outline"] || "#90909a"
	readonly property string outlineVariant: values["outlineVariant"] || "#46464f"
	readonly property string surfaceContainerLowest: values["surfaceContainerLowest"] || "#0e0e12"
	readonly property string surfaceContainerLow: values["surfaceContainerLow"] || "#1b1b1f"
	readonly property string surfaceContainer: values["surfaceContainer"] || "#1f1f23"
	readonly property string surfaceContainerHigh: values["surfaceContainerHigh"] || "#2a2a2e"
	readonly property string surfaceContainerHighest: values["surfaceContainerHighest"] || "#353438"
	readonly property string surfaceBright: values["surfaceBright"] || "#39393d"
	readonly property string shadow: values["shadow"] || "#000000"
	readonly property string scrim: values["scrim"] || "#000000"
	readonly property string surfaceTint: values["surfaceTint"] || "#bac3ff"
	readonly property string inverseSurface: values["inverseSurface"] || "#e4e1e7"
	readonly property string inverseOnSurface: values["inverseOnSurface"] || "#303034"
	readonly property string inversePrimary: values["inversePrimary"] || "#525b92"
	readonly property string success: values["success"] || "#B5CCBA"
	readonly property string onSuccess: values["onSuccess"] || "#213528"

	readonly property string rosewater: values["rosewater"] || "#f6eff9"
	readonly property string flamingo: values["flamingo"] || "#e7def4"
	readonly property string mauve: values["mauve"] || "#b9baff"
	readonly property string red: values["red"] || "#b9a8ff"
	readonly property string peach: values["peach"] || "#e0c2f9"
	readonly property string yellow: values["yellow"] || "#ffecf3"
	readonly property string green: values["green"] || "#c8e3ff"
	readonly property string teal: values["teal"] || "#d0e0ff"
	readonly property string sky: values["sky"] || "#ccdbff"
	readonly property string sapphire: values["sapphire"] || "#b1c6ff"
	readonly property string blue: values["blue"] || "#aab9ff"
	readonly property string lavender: values["lavender"] || "#c2c9ff"
	readonly property string text: values["text"] || "#e4e1e7"
	readonly property string subtext1: values["subtext1"] || "#c6c5d1"
	readonly property string subtext0: values["subtext0"] || "#90909a"
	readonly property string overlay2: values["overlay2"] || "#7d7d86"
	readonly property string overlay1: values["overlay1"] || "#6a6a72"
	readonly property string overlay0: values["overlay0"] || "#595960"
	readonly property string surface2: values["surface2"] || "#48484e"
	readonly property string surface1: values["surface1"] || "#37373d"
	readonly property string surface0: values["surface0"] || "#25252a"
	readonly property string base: values["base"] || "#131317"
	readonly property string mantle: values["mantle"] || "#131317"
	readonly property string crust: values["crust"] || "#121216"
}
