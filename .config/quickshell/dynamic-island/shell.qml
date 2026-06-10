//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma ShellId dynamic-island

import Quickshell
import Quickshell.Io
import "config"

ShellRoot {
	settings.watchFiles: true

	Variants {
		model: Quickshell.screens

		DynamicIsland {
			property var modelData
			screen: modelData
		}
	}
}
