import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../config"
import "../services"
import "VectorIcons"
import "."

Item {
	id: settingsPanel
	clip: true

	property string hostname: ""
	property string kernel: ""
	property string uptimeStr: ""

	Process {
		id: hostnameProc
		stdout: StdioCollector {
			onStreamFinished: settingsPanel.hostname = text.trim()
		}
	}

	Process {
		id: kernelProc
		stdout: StdioCollector {
			onStreamFinished: settingsPanel.kernel = text.trim()
		}
	}

	Process {
		id: uptimeProc
		stdout: StdioCollector {
			onStreamFinished: settingsPanel.uptimeStr = text.trim()
		}
	}

	Process {
		id: brightnessReadProc
		stdout: StdioCollector {
			onStreamFinished: {
				var val = parseInt(text.trim())
				if (!isNaN(val)) brightnessBar.brightnessValue = Math.round(val / 255 * 100)
			}
		}
	}

	Process {
		id: brightnessWriteProc
	}

	function refreshSystemInfo() {
		hostnameProc.exec(["hostname"])
		kernelProc.exec(["uname", "-r"])
		uptimeProc.exec(["sh", "-c", "awk '{print int($1/3600)\"h \"int(($1%3600)/60)\"m\"}' /proc/uptime"])
	}

	Component.onCompleted: refreshSystemInfo()

	ColumnLayout {
		anchors.fill: parent
		spacing: 6

		Text {
			text: "System"
			color: Colors.onSurface
			font.pixelSize: 14
			font.weight: Font.Bold
			Layout.topMargin: 4
		}

		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: 72
			radius: 8
			color: Colors.surfaceVariant

			Column {
				anchors.fill: parent
				anchors.margins: 8
				spacing: 4

				Text {
					text: "Hostname: " + (settingsPanel.hostname || "...")
					color: Colors.onSurface
					font.pixelSize: 12
				}
				Text {
					text: "Kernel: " + (settingsPanel.kernel || "...")
					color: Colors.onSurfaceVariant
					font.pixelSize: 11
				}
				Text {
					text: "Uptime: " + (settingsPanel.uptimeStr || "...")
					color: Colors.onSurfaceVariant
					font.pixelSize: 11
				}
			}
		}

		Text {
			text: "Audio"
			color: Colors.onSurfaceVariant
			font.pixelSize: 11
			font.weight: Font.Medium
		}

		Row {
			Layout.fillWidth: true
			Layout.preferredHeight: 24
			spacing: 6

			SpeakerIcon {
				level: (Audio.volumePercent || 0)
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

		Text {
			text: "Display"
			color: Colors.onSurfaceVariant
			font.pixelSize: 11
			font.weight: Font.Medium
		}

		Row {
			Layout.fillWidth: true
			Layout.preferredHeight: 24
			spacing: 6

			BrightnessIcon {
				iconColor: Colors.yellow
				anchors.verticalCenter: parent.verticalCenter
			}

			Item {
				id: brightnessBar
				height: 24
				Layout.fillWidth: true

				property int brightnessValue: 100

				Component.onCompleted: brightnessReadProc.exec(["sh", "-c", "brightnessctl get"])

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width; height: 6; radius: 3
					color: Colors.surfaceContainer
				}
				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width * (brightnessBar.brightnessValue / 100); height: 6; radius: 3
					color: Colors.yellow
				}
				MouseArea {
					anchors.fill: parent
					onClicked: {
						var pct = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)))
						var val = Math.round(pct / 100 * 255)
						brightnessWriteProc.exec(["brightnessctl", "set", String(val)])
						brightnessBar.brightnessValue = pct
					}
					onPositionChanged: if (pressed) {
						var pct = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)))
						var val = Math.round(pct / 100 * 255)
						brightnessWriteProc.exec(["brightnessctl", "set", String(val)])
						brightnessBar.brightnessValue = pct
					}
				}
			}

			Text {
				text: brightnessBar.brightnessValue + "%"
				color: Colors.onSurface
				font.pixelSize: 12
				font.weight: Font.Medium
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		Item { Layout.fillHeight: true }

		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: 32
			radius: 8
			color: Colors.surfaceVariant

			Row {
				anchors.centerIn: parent
				spacing: 6

				Shape {
					width: 14; height: 14
					anchors.verticalCenter: parent.verticalCenter
					ShapePath {
						strokeColor: Colors.primary
						strokeWidth: 2
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						PathMove { x: 7; y: 2 }
						PathLine { x: 7; y: 7 }
						PathMove { x: 2; y: 7 }
						PathLine { x: 12; y: 12 }
						PathMove { x: 12; y: 7 }
						PathLine { x: 2; y: 12 }
					}
				}

				Text {
					text: "Reload Configuration"
					color: Colors.primary
					font.pixelSize: 12
					font.weight: Font.Medium
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: {
					Quickshell.restart()
				}
			}
		}
	}
}
