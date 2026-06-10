import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import "config"
import "components"
import "components/VectorIcons"
import "services"

PanelWindow {
	id: root

	property var modelData
	screen: modelData

	anchors.top: true
	anchors.left: true
	anchors.right: true

	implicitHeight: isTall ? tallHeight
		: islandState === "power" ? powerHeight + verticalMargin * 2
		: islandState === "polkit" ? polkitHeight + verticalMargin * 2
		: isMedium ? notifHeight + verticalMargin * 2
		: pillHeight + verticalMargin * 2
	color: "transparent"

	WlrLayershell.layer: WlrLayer.Top
	exclusiveZone: 0

	property real pillHeight: 38
	property real notifHeight: 64
	property real tallHeight: 500
	property real powerHeight: 200
	property real polkitHeight: 130
	property real verticalMargin: 8
	property real pillPadding: 14
	property real expandedWidth: 650

	property string islandState: "idle"
	property bool pinned: false

	readonly property bool isTall: islandState === "launcher"
		|| islandState === "control"
		|| islandState === "theme"
		|| islandState === "settings"

	readonly property bool isMedium: islandState === "notification"

	property string osdMode: "volume"
	property int osdValue: 50

	readonly property string osdLabel: osdMode === "volume" ? "Volume" : "Brightness"

	property real notifCountdown: 1.0
	property real notifDuration: 5.0

	property string launcherQuery: ""
	property int launcherSelectedIndex: 0
	property bool cliphistLoaded: false
	property var cliphistData: []

	readonly property string launcherMode: {
		if (launcherQuery.startsWith("=")) return "calc"
		if (launcherQuery.startsWith(":")) return "cliphist"
		return "apps"
	}

	readonly property string calcResult: {
		if (launcherMode !== "calc") return ""
		var expr = launcherQuery.substring(1)
		try {
			return String(eval(expr))
		} catch (e) {
			return "Error"
		}
	}

	Timer {
		id: osdTimer
		interval: 1500
		onTriggered: {
			if (root.islandState === "osd") {
				root.islandState = "idle"
			}
		}
	}

	Timer {
		id: notifTimer
		interval: 50
		repeat: true
		onTriggered: {
			if (root.islandState !== "notification") return
			root.notifCountdown -= 50 / 1000
			if (root.notifCountdown <= 0) {
				root.notifCountdown = 0
				NotificationDaemon.dismissCurrent()
			}
		}
	}

	ListModel { id: appResultsModel }
	ListModel { id: cliphistResultsModel }

	Timer {
		id: launcherUpdateTimer
		interval: 80
		onTriggered: {
			root.updateLauncherResults()
			if (root.launcherMode === "cliphist" && !root.cliphistLoaded && root.islandState === "launcher") {
				root.loadCliphistData()
			}
		}
	}

	function readNotification() {
		var n = NotificationDaemon.currentNotification
		if (n) {
			notifDuration = Math.max(n.expireTimeout || 5, 3)
			notifCountdown = notifDuration
			islandState = "notification"
		}
	}

	onIslandStateChanged: {
		if (islandState === "osd") {
			osdTimer.restart()
		} else {
			osdTimer.stop()
		}
		if (islandState === "notification") {
			notifTimer.start()
		} else {
			notifTimer.stop()
		}
		if (islandState === "launcher") {
			launcherSelectedIndex = 0
			launcherQuery = ""
			updateLauncherResults()
		}
		if (islandState === "control") {
			launcherSelectedIndex = 0
		}
		if (islandState !== "polkit") {
			polkitContent.clear()
		}
	}

	Connections {
		target: NotificationDaemon
		function onCurrentNotificationChanged() {
			root.readNotification()
		}
	}

	function showVolumeOSD() {
		osdMode = "volume"
		osdValue = Audio.volumePercent
		islandState = "osd"
	}

	function showBrightnessOSD() {
		osdMode = "brightness"
		var proc = Process.exec("brightnessctl", ["get"])
		proc.onStdout.connect(function(data) {
			var max = 255
			var val = parseInt(data.trim())
			if (!isNaN(val)) {
				osdValue = Math.round(val / max * 100)
			}
		})
		islandState = "osd"
	}

	function showPowerMenu() {
		islandState = "power"
	}

	function showPolkit(message, action) {
		polkitContent.show(message, action)
		islandState = "polkit"
	}

	function loadCliphistData() {
		var proc = Process.exec("cliphist", ["list"])
		proc.onStdout.connect(function(data) {
			var result = []
			var lines = data.trim().split("\n")
			for (var i = 0; i < lines.length; i++) {
				var parts = lines[i].split("\t")
				if (parts.length >= 2) {
					result.push({
						id: parseInt(parts[0]),
						preview: parts.slice(1).join("\t")
					})
				}
			}
			cliphistData = result
			cliphistLoaded = true
			root.updateLauncherResults()
		})
	}

	function updateLauncherResults() {
		if (root.islandState !== "launcher") return
		launcherSelectedIndex = 0
		var q = launcherQuery.toLowerCase()

		if (launcherMode === "apps") {
			appResultsModel.clear()
			for (var i = 0; i < DesktopEntries.applications.count; i++) {
				var entry = DesktopEntries.applications.get(i)
				var name = entry.name.toLowerCase()
				var comment = (entry.comment || "").toLowerCase()
				var generic = (entry.genericName || "").toLowerCase()

				if (name.includes(q) || comment.includes(q) || generic.includes(q)) {
					appResultsModel.append({
						desktopEntry: entry,
						name: entry.name,
						icon: entry.icon,
						comment: entry.comment || entry.genericName || ""
					})
				}
			}
		} else if (launcherMode === "cliphist" && cliphistLoaded) {
			cliphistResultsModel.clear()
			var search = launcherQuery.substring(1).toLowerCase()
			for (var i = 0; i < cliphistData.length; i++) {
				if (cliphistData[i].preview.toLowerCase().includes(search)) {
					cliphistResultsModel.append({
						id: cliphistData[i].id,
						preview: cliphistData[i].preview
					})
				}
			}
		}
	}

	function getLauncherResultCount() {
		if (launcherMode === "apps") return appResultsModel.count
		if (launcherMode === "cliphist") return cliphistResultsModel.count
		return 0
	}

	function launchSelected() {
		if (launcherMode === "apps") {
			if (launcherSelectedIndex >= 0 && launcherSelectedIndex < appResultsModel.count) {
				var entryData = appResultsModel.get(launcherSelectedIndex)
				if (entryData.desktopEntry) {
					entryData.desktopEntry.execute()
				}
				islandState = "idle"
			}
		} else if (launcherMode === "calc") {
			if (calcResult && calcResult !== "Error") {
				Process.exec("wl-copy", [calcResult])
			}
			islandState = "idle"
		} else if (launcherMode === "cliphist") {
			if (launcherSelectedIndex >= 0 && launcherSelectedIndex < cliphistResultsModel.count) {
				var item = cliphistResultsModel.get(launcherSelectedIndex)
				Process.exec("bash", ["-c", "cliphist decode " + item.id + " | wl-copy"])
				islandState = "idle"
			}
		}
	}

	readonly property real currentPillWidth: {
		if (islandState === "expanded") return expandedWidth
		if (islandState === "osd") return 280
		if (islandState === "notification") return 420
		if (islandState === "power") return 420
		if (islandState === "polkit") return 400
		if (isTall) return 500
		if (islandState === "idle") return Math.max(130, idleContent.width + pillPadding * 2)
		return 130
	}

	Rectangle {
		id: pill
		anchors.horizontalCenter: parent.horizontalCenter
		y: root.verticalMargin

		width: root.currentPillWidth
		height: root.isTall ? root.tallHeight - root.verticalMargin * 2
			: root.islandState === "power" ? root.powerHeight
			: root.islandState === "polkit" ? root.polkitHeight
			: root.isMedium ? root.notifHeight
			: root.pillHeight

		radius: Math.min(width, root.isTall ? tallHeight
			: root.islandState === "power" ? root.powerHeight
			: root.islandState === "polkit" ? root.polkitHeight
			: root.isMedium ? root.notifHeight
			: root.pillHeight) / 2
		color: Colors.surfaceContainer

		clip: root.isTall || root.islandState === "power" || root.islandState === "polkit"

		Behavior on width {
			SpringAnimation {}
		}

		Behavior on height {
			SpringAnimation {}
		}

		layer.enabled: true
		layer.effect: MultiEffect {
			shadowEnabled: true
			shadowColor: "#80000000"
			shadowBlur: 0.5
			shadowHorizontalOffset: 0
			shadowVerticalOffset: 2
			shadowOpacity: 0.4
		}

		Row {
			id: idleContent
			anchors.centerIn: parent
			spacing: 8
			visible: root.islandState === "idle"

			EqVisualizer {
				active: MprisManager.isPlaying
				barColor: Colors.primary
				anchors.verticalCenter: parent.verticalCenter
			}

			Text {
				id: timeText
				color: Colors.onSurface
				font.pixelSize: 14
				font.weight: Font.Medium
				text: Qt.formatDateTime(clock.date, "HH:mm")
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		Item {
			id: notifContent
			anchors.fill: parent
			anchors.margins: 8
			visible: root.islandState === "notification"
			clip: true

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onContainsMouseChanged: {
					if (containsMouse) {
						notifTimer.stop()
					} else if (root.islandState === "notification") {
						notifTimer.start()
					}
				}
				onClicked: NotificationDaemon.dismissCurrent()
			}

			Row {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.bottom: countdownBar.top
				anchors.bottomMargin: 4
				spacing: 8

				IconImage {
					id: notifIcon
					source: NotificationDaemon.currentNotification?.appIcon ?? ""
					implicitWidth: 22
					implicitHeight: 22
					anchors.verticalCenter: parent.verticalCenter
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width - notifIcon.width - parent.spacing
					spacing: 2

					Text {
						width: parent.width
						elide: Text.ElideRight
						color: NotificationDaemon.currentNotification?.urgency === NotificationUrgency.Critical ? Colors.error : Colors.onSurface
						font.pixelSize: 12
						font.weight: Font.Bold
						text: NotificationDaemon.currentNotification?.summary ?? ""
					}

					Text {
						width: parent.width
						elide: Text.ElideRight
						color: Colors.onSurfaceVariant
						font.pixelSize: 11
						textFormat: Text.PlainText
						text: NotificationDaemon.currentNotification?.body ?? ""
						maximumLineCount: 2
					}
				}
			}

			ProgressBar {
				id: countdownBar
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				barHeight: 3
				value: root.notifDuration > 0 ? root.notifCountdown / root.notifDuration : 0
				accentColor: NotificationDaemon.currentNotification?.urgency === NotificationUrgency.Critical ? Colors.error : Colors.primary
			}
		}

		Row {
			id: osdContent
			anchors.centerIn: parent
			spacing: 10
			visible: root.islandState === "osd"

			SpeakerIcon {
				level: root.osdMode === "volume" ? root.osdValue : 100
				iconColor: Colors.primary
				anchors.verticalCenter: parent.verticalCenter
				visible: root.osdMode === "volume"
			}

			BrightnessIcon {
				iconColor: Colors.yellow
				anchors.verticalCenter: parent.verticalCenter
				visible: root.osdMode === "brightness"
			}

			ProgressBar {
				value: root.osdValue / 100
				accentColor: root.osdMode === "volume" ? Colors.primary : Colors.yellow
				barHeight: 6
				implicitWidth: 140
				anchors.verticalCenter: parent.verticalCenter
			}

			Text {
				color: Colors.onSurface
				font.pixelSize: 12
				font.weight: Font.Medium
				text: root.osdValue + "%"
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		Item {
			id: expandedContent
			anchors.fill: parent
			anchors.margins: 8
			visible: root.islandState === "expanded"

			Row {
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				width: 100
				spacing: 8

				MediaIconButton {
					iconType: "prev"
					iconColor: Colors.onSurface
					onClicked: MprisManager.activePlayer?.previous()
				}

				MediaIconButton {
					iconType: MprisManager.isPlaying ? "pause" : "play"
					iconColor: Colors.primary
					size: 18
					onClicked: {
						if (MprisManager.isPlaying)
							MprisManager.activePlayer?.pause()
						else
							MprisManager.activePlayer?.play()
					}
				}

				MediaIconButton {
					iconType: "next"
					iconColor: Colors.onSurface
					onClicked: MprisManager.activePlayer?.next()
				}
			}

			Item {
				anchors.centerIn: parent
				width: clockCol.width
				height: clockCol.height

				Column {
					id: clockCol
					spacing: 2

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						color: Colors.onSurface
						font.pixelSize: 16
						font.weight: Font.Bold
						text: Qt.formatDateTime(clock.date, "HH:mm")
					}

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						color: Colors.onSurfaceVariant
						font.pixelSize: 10
						text: Qt.formatDateTime(clock.date, "ddd, MMM d")
					}
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: root.islandState = "control"
				}
			}

			Row {
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				width: 100
				spacing: 6

				Repeater {
					model: SystemTray.items

					IconImage {
						required property var modelData
						source: modelData.icon
						implicitWidth: 16
						implicitHeight: 16
					}
				}
			}
		}

		Item {
			id: launcherContent
			anchors.fill: parent
			anchors.margins: 10
			visible: root.islandState === "launcher"
			clip: true

			Column {
				anchors.fill: parent
				spacing: 8

				Rectangle {
					id: searchBar
					width: parent.width
					height: 36
					radius: 8
					color: Colors.surfaceVariant

					Row {
						anchors.fill: parent
						anchors.leftMargin: 10
						anchors.rightMargin: 10
						spacing: 6

						Text {
							id: prefixText
							text: root.launcherMode === "calc" ? "=" : root.launcherMode === "cliphist" ? ":" : ""
							color: Colors.primary
							font.pixelSize: 14
							font.weight: Font.Bold
							anchors.verticalCenter: parent.verticalCenter
							visible: text !== ""
						}

						TextInput {
							id: queryInput
							anchors.verticalCenter: parent.verticalCenter
							width: parent.width - (prefixText.visible ? prefixText.width + parent.spacing : 0)
							color: Colors.onSurface
							font.pixelSize: 14
							focus: root.islandState === "launcher"

							Text {
								text: root.launcherMode === "calc" ? "Enter expression..." : root.launcherMode === "cliphist" ? "Search clipboard..." : "Search applications..."
								color: Colors.onSurfaceVariant
								font.pixelSize: 14
								visible: queryInput.text === ""
								anchors.verticalCenter: parent.verticalCenter
							}

							onTextChanged: {
								root.launcherQuery = text
								launcherUpdateTimer.restart()
							}

							Keys.onPressed: function(event) {
								switch (event.key) {
									case Qt.Key_Return:
									case Qt.Key_Enter:
										root.launchSelected()
										break
									case Qt.Key_Escape:
										root.islandState = "idle"
										break
									case Qt.Key_Up:
										root.launcherSelectedIndex = Math.max(0, root.launcherSelectedIndex - 1)
										break
									case Qt.Key_Down:
										var max = root.getLauncherResultCount() - 1
										root.launcherSelectedIndex = Math.min(max, root.launcherSelectedIndex + 1)
										break
								}
							}
						}
					}
				}

				Item {
					width: parent.width
					height: parent.height - searchBar.height - parent.spacing
					clip: true

					ListView {
						id: launcherList
						anchors.fill: parent
						visible: root.launcherMode !== "calc"
						currentIndex: root.launcherSelectedIndex
						boundsBehavior: Flickable.StopAtBounds
						keyNavigationWraps: false
						spacing: 2

						model: root.launcherMode === "apps" ? appResultsModel
							: root.launcherMode === "cliphist" ? cliphistResultsModel
							: null

						delegate: Item {
							width: parent ? parent.width : 0
							height: 40

							Rectangle {
								anchors.fill: parent
								radius: 6
								color: ListView.isCurrentItem ? Colors.surfaceVariant : "transparent"

								Row {
									anchors.fill: parent
									anchors.leftMargin: 8
									anchors.rightMargin: 8
									spacing: 8

									IconImage {
										source: model.icon
										implicitWidth: 20
										implicitHeight: 20
										anchors.verticalCenter: parent.verticalCenter
									}

									Column {
										anchors.verticalCenter: parent.verticalCenter
										width: parent.width - 28 - parent.spacing
										spacing: 1

										Text {
											width: parent.width
											elide: Text.ElideRight
											text: root.launcherMode === "cliphist" ? model.preview : model.name
											color: Colors.onSurface
											font.pixelSize: 12
										}

										Text {
											width: parent.width
											elide: Text.ElideRight
											text: root.launcherMode === "apps" ? model.comment : ""
											color: Colors.onSurfaceVariant
											font.pixelSize: 10
											visible: text !== ""
										}
									}
								}
							}

							MouseArea {
								anchors.fill: parent
								onClicked: {
									root.launcherSelectedIndex = index
									root.launchSelected()
								}
							}
						}
					}

					Text {
						anchors.centerIn: parent
						visible: root.launcherMode === "calc"
						color: Colors.onSurface
						font.pixelSize: 16
						font.weight: Font.Bold
						text: root.launcherQuery.substring(1) + " = " + root.calcResult
					}

					Text {
						anchors.centerIn: parent
						visible: root.launcherMode === "apps" && appResultsModel.count === 0 && root.launcherQuery.length > 0
						color: Colors.onSurfaceVariant
						font.pixelSize: 12
						text: "No matching applications"
					}

					Text {
						anchors.centerIn: parent
						visible: root.launcherMode === "cliphist" && !root.cliphistLoaded
						color: Colors.onSurfaceVariant
						font.pixelSize: 12
						text: "Loading clipboard history..."
					}

					Text {
						anchors.centerIn: parent
						visible: root.launcherMode === "cliphist" && root.cliphistLoaded && cliphistResultsModel.count === 0 && root.launcherQuery.length > 1
						color: Colors.onSurfaceVariant
						font.pixelSize: 12
						text: "No matching clipboard entries"
					}
				}
			}
		}

		ControlCenter {
			id: controlContent
			anchors.fill: parent
			anchors.margins: 10
			visible: root.islandState === "control"
			clip: true
			focus: root.islandState === "control"

			Keys.onPressed: function(event) {
				if (event.key === Qt.Key_Escape) {
					root.islandState = "idle"
				}
			}

			onPowerMenuRequested: root.islandState = "power"
			onThemeRequested: root.islandState = "theme"
			onSettingsRequested: root.islandState = "settings"
		}

		ThemePanel {
			anchors.fill: parent
			anchors.margins: 10
			visible: root.islandState === "theme"
			clip: true
			focus: root.islandState === "theme"

			Keys.onPressed: function(event) {
				if (event.key === Qt.Key_Escape) {
					root.islandState = "idle"
				}
			}
		}

		SettingsPanel {
			anchors.fill: parent
			anchors.margins: 10
			visible: root.islandState === "settings"
			clip: true
			focus: root.islandState === "settings"

			Keys.onPressed: function(event) {
				if (event.key === Qt.Key_Escape) {
					root.islandState = "idle"
				}
			}
		}

		PowerMenu {
			anchors.fill: parent
			anchors.margins: 10
			visible: root.islandState === "power"
			clip: true
		}

		PolkitPrompt {
			id: polkitContent
			anchors.fill: parent
			anchors.margins: 10
			visible: root.islandState === "polkit"
			clip: true
			focus: root.islandState === "polkit"

			Keys.onPressed: function(event) {
				if (event.key === Qt.Key_Escape) {
					root.islandState = "idle"
				}
			}

			onAuthenticated: function(password) {
				root.islandState = "idle"
			}

			onCancelled: {
				root.islandState = "idle"
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton

		onContainsMouseChanged: {
			if (root.islandState === "osd" || root.islandState === "notification") return
			if (root.islandState === "expanded" || root.islandState === "launcher" || root.islandState === "control" || root.islandState === "power" || root.islandState === "polkit" || root.islandState === "theme" || root.islandState === "settings") return
			if (containsMouse && !root.pinned) {
				root.islandState = "expanded"
			} else if (!containsMouse && !root.pinned && root.islandState === "expanded") {
				root.islandState = "idle"
			}
		}

		onClicked: function(mouse) {
			if (mouse.button === Qt.RightButton) {
				root.islandState = "idle"
				root.pinned = false
			}
		}
	}

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
}
