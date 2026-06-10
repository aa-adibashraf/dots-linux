import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../config"
import "../services"
import "VectorIcons"
import "."

Item {
	id: control
	clip: true

	signal powerMenuRequested()
	signal themeRequested()
	signal settingsRequested()

	ColumnLayout {
		anchors.fill: parent
		spacing: 6

		// Quick Toggles
		GridLayout {
			columns: 4
			columnSpacing: 5
			rowSpacing: 5
			Layout.fillWidth: true

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				radius: 8
				color: NotificationDaemon.dndEnabled ? Colors.primaryContainer : Colors.surfaceContainer
				border.color: NotificationDaemon.dndEnabled ? Colors.primary : "transparent"
				border.width: 1

				Text {
					anchors.centerIn: parent
					text: "DND"
					color: NotificationDaemon.dndEnabled ? Colors.onPrimaryContainer : Colors.onSurfaceVariant
					font.pixelSize: 11
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: NotificationDaemon.toggleDnd()
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				radius: 8
				color: (Audio.muted || false) ? Colors.errorContainer : Colors.surfaceContainer
				border.color: (Audio.muted || false) ? Colors.error : "transparent"
				border.width: 1

				Text {
					anchors.centerIn: parent
					text: "Mute"
					color: (Audio.muted || false) ? Colors.onErrorContainer : Colors.onSurfaceVariant
					font.pixelSize: 11
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: Audio.toggleMute()
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				radius: 8
				color: Colors.surfaceContainer

				Text {
					anchors.centerIn: parent
					text: "Snip"
					color: Colors.onSurfaceVariant
					font.pixelSize: 11
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: Process.exec("bash", ["-c", "hyprctl keyword decoration:drop_shadow 0; grim -g \"$(slurp)\" - | wl-copy -t image/png; hyprctl keyword decoration:drop_shadow 1"])
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				radius: 8
				color: Colors.surfaceContainer

				Text {
					anchors.centerIn: parent
					text: "Lock"
					color: Colors.onSurfaceVariant
					font.pixelSize: 11
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: Process.exec("hyprlock", [])
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				radius: 8
				color: Colors.surfaceContainer

				Text {
					anchors.centerIn: parent
					text: "Theme"
					color: Colors.primary
					font.pixelSize: 11
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: control.themeRequested()
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				radius: 8
				color: Colors.surfaceContainer

				Text {
					anchors.centerIn: parent
					text: "Settings"
					color: Colors.primary
					font.pixelSize: 11
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: control.settingsRequested()
				}
			}
		}

		// Audio Card
		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: 155
			radius: 10
			color: Colors.surfaceVariant
			clip: true

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 6

				Row {
					spacing: 10

					Rectangle {
						width: 56; height: 56; radius: 8
						color: Colors.surfaceContainer

						Image {
							id: albumArt
							anchors.fill: parent
							source: MprisManager.artUrl
							fillMode: Image.PreserveAspectCrop
							asynchronous: true
							visible: status === Image.Ready
						}

						Rectangle {
							anchors.fill: parent
							radius: 8
							color: Colors.primaryContainer
							visible: !albumArt.visible || MprisManager.artUrl.toString() === ""

							Text {
								anchors.centerIn: parent
								text: "\u266A"
								color: Colors.onPrimaryContainer
								font.pixelSize: 22
							}
						}
					}

					Column {
						anchors.verticalCenter: parent.verticalCenter
						width: parent.width - 66
						spacing: 1

						Text {
							width: parent.width; elide: Text.ElideRight
							text: MprisManager.trackTitle || "No media playing"
							color: Colors.onSurface
							font.pixelSize: 14; font.weight: Font.Bold
						}

						Text {
							width: parent.width; elide: Text.ElideRight
							text: MprisManager.artist || ""
							color: Colors.onSurfaceVariant
							font.pixelSize: 12
							visible: text !== ""
						}

						Text {
							width: parent.width; elide: Text.ElideRight
							text: MprisManager.album || ""
							color: Colors.onSurfaceVariant
							font.pixelSize: 11
							visible: text !== ""
						}
					}
				}

				ProgressBar {
					width: parent.width
					barHeight: 4
					value: MprisManager.trackLength > 0 ? MprisManager.position / MprisManager.trackLength : 0
					accentColor: Colors.primary
				}

				Row {
					spacing: 8
					anchors.horizontalCenter: parent.horizontalCenter

					MediaIconButton { iconType: "prev"; iconColor: Colors.onSurface; size: 18; onClicked: MprisManager.activePlayer?.previous() }
					MediaIconButton {
						iconType: MprisManager.isPlaying ? "pause" : "play"
						iconColor: Colors.primary
						size: 22
						onClicked: {
							if (MprisManager.isPlaying)
								MprisManager.activePlayer?.pause()
							else
								MprisManager.activePlayer?.play()
						}
					}
					MediaIconButton { iconType: "next"; iconColor: Colors.onSurface; size: 18; onClicked: MprisManager.activePlayer?.next() }
				}
			}
		}

		// Volume Slider
		Row {
			Layout.fillWidth: true
			Layout.preferredHeight: 24
			spacing: 6

			SpeakerIcon {
				level: Audio.volumePercent || 0
				iconColor: (Audio.muted || false) ? Colors.onSurfaceVariant : Colors.primary
				anchors.verticalCenter: parent.verticalCenter
			}

			Item {
				height: 24
				Layout.fillWidth: true

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width; height: 6; radius: 3
					color: Colors.surfaceContainer
				}

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width * ((Audio.volumePercent || 0) / 100); height: 6; radius: 3
					color: (Audio.muted || false) ? Colors.onSurfaceVariant : Colors.primary
				}

				MouseArea {
					anchors.fill: parent
					onClicked: Audio.setVolume(Math.max(0, Math.min(1, mouse.x / width)))
					onPositionChanged: if (pressed) Audio.setVolume(Math.max(0, Math.min(1, mouse.x / width)))
				}
			}

			Text {
				text: (Audio.volumePercent || 0) + "%"
				color: Colors.onSurface
				font.pixelSize: 12
				font.weight: Font.Medium
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		// Notification History Header
		Row {
			Layout.fillWidth: true
			Layout.preferredHeight: 20
			spacing: 8

			Text {
				text: "Notifications"
				color: Colors.onSurface
				font.pixelSize: 13
				font.weight: Font.Bold
			}

			Item { Layout.fillWidth: true }

			Text {
				text: "Clear All"
				color: NotificationDaemon.notificationHistory && NotificationDaemon.notificationHistory.length > 0 ? Colors.primary : Colors.onSurfaceVariant
				font.pixelSize: 11
				visible: NotificationDaemon.notificationHistory ? NotificationDaemon.notificationHistory.length > 0 : false

				MouseArea {
					anchors.fill: parent
					anchors.margins: -4
					onClicked: NotificationDaemon.clearHistory()
				}
			}

			Item {
				width: 16; height: 16
				anchors.verticalCenter: parent.verticalCenter

				Shape {
					anchors.fill: parent
					antialiasing: true
					ShapePath {
						strokeColor: Colors.onSurfaceVariant
						strokeWidth: 1.5
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						PathMove { x: 8; y: 2 }
						PathLine { x: 8; y: 9 }
					}
					ShapePath {
						strokeColor: Colors.onSurfaceVariant
						strokeWidth: 1.5
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						PathMove { x: 8; y: 2 }
						PathLine { x: 8; y: 9 }
					}
					ShapePath {
						strokeColor: Colors.onSurfaceVariant
						strokeWidth: 1.5
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						PathMove { x: 3; y: 14 }
						PathLine { x: 13; y: 14 }
						PathMove { x: 8; y: 9 }
						PathLine { x: 3; y: 14 }
						PathMove { x: 8; y: 9 }
						PathLine { x: 13; y: 14 }
					}
				}

				MouseArea {
					anchors.fill: parent
					anchors.margins: -4
					onClicked: control.powerMenuRequested()
				}
			}
		}

		// Notification History List
		ListView {
			id: notifList
			Layout.fillWidth: true
			Layout.fillHeight: true
			clip: true
			spacing: 2

			model: NotificationDaemon.notificationHistory ? NotificationDaemon.notificationHistory.slice(-20).reverse() : []

			delegate: Rectangle {
				width: notifList.width
				height: 42
				radius: 6
				color: Colors.surfaceContainer

				Row {
					anchors.fill: parent
					anchors.margins: 6
					spacing: 6

					IconImage {
						source: modelData.appIcon
						implicitWidth: 18; implicitHeight: 18
						anchors.verticalCenter: parent.verticalCenter
					}

					Column {
						anchors.verticalCenter: parent.verticalCenter
						width: parent.width - 24 - 50 - 12
						spacing: 1

						Text {
							width: parent.width; elide: Text.ElideRight
							text: modelData.summary
							color: modelData.urgency === NotificationUrgency.Critical ? Colors.error : Colors.onSurface
							font.pixelSize: 11
							font.weight: Font.Medium
						}

						Text {
							width: parent.width; elide: Text.ElideRight
							text: modelData.body
							color: Colors.onSurfaceVariant
							font.pixelSize: 10
							visible: text !== ""
							maximumLineCount: 1
						}
					}

					Text {
						text: {
							if (!modelData.time) return ""
							var diff = Math.floor((new Date() - modelData.time) / 1000)
							if (diff < 10) return "now"
							if (diff < 60) return diff + "s"
							if (diff < 3600) return Math.floor(diff / 60) + "m"
							if (diff < 86400) return Math.floor(diff / 3600) + "h"
							return Math.floor(diff / 86400) + "d"
						}
						color: Colors.onSurfaceVariant
						font.pixelSize: 10
						anchors.verticalCenter: parent.verticalCenter
					}
				}

				MouseArea {
					anchors.fill: parent
					onClicked: {
						var idx = NotificationDaemon.notificationHistory.indexOf(modelData)
						if (idx >= 0) NotificationDaemon.removeHistory(idx)
					}
				}
			}

			Text {
				anchors.centerIn: parent
				text: "No notifications"
				color: Colors.onSurfaceVariant
				font.pixelSize: 12
				visible: notifList.count === 0
			}
		}
	}
}
