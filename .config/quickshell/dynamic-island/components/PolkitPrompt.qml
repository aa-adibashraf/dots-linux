import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import "../config"

Item {
	id: polkit
	clip: true

	property string authMessage: ""
	property string authAction: ""
	signal authenticated(string password)
	signal cancelled()

	function show(message, action) {
		authMessage = message
		authAction = action
		passwordInput.forceActiveFocus()
	}

	function clear() {
		passwordInput.text = ""
		authMessage = ""
	}

	ColumnLayout {
		anchors.fill: parent
		anchors.margins: 10
		spacing: 8

		Row {
			spacing: 8
			Layout.fillWidth: true

			Item {
				width: 24; height: 24
				anchors.verticalCenter: parent.verticalCenter

				Shape {
					anchors.fill: parent
					antialiasing: true
					ShapePath {
						strokeColor: "transparent"
						fillColor: Colors.yellow
						joinStyle: ShapePath.RoundJoin

						PathMove { x: 12; y: 2 }
						PathLine { x: 21; y: 21 }
						PathLine { x: 3; y: 21 }
						PathLine { x: 12; y: 2 }
					}
					ShapePath {
						strokeColor: Colors.onSurface
						strokeWidth: 1.5
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						PathMove { x: 12; y: 9 }
						PathLine { x: 12; y: 14 }
						PathMove { x: 12; y: 16 }
						PathLine { x: 12; y: 17 }
					}
				}
			}

			Text {
				text: "Authentication Required"
				color: Colors.onSurface
				font.pixelSize: 13
				font.weight: Font.Bold
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		Text {
			text: polkit.authMessage || "An application requires elevated privileges"
			color: Colors.onSurfaceVariant
			font.pixelSize: 11
			wrapMode: Text.WordWrap
			Layout.fillWidth: true
			maximumLineCount: 2
		}

		Rectangle {
			height: 32
			radius: 8
			color: Colors.surfaceContainer
			Layout.fillWidth: true

			TextInput {
				id: passwordInput
				anchors.fill: parent
				anchors.leftMargin: 10
				anchors.rightMargin: 10
				echoMode: TextInput.Password
				color: Colors.onSurface
				font.pixelSize: 13
				focus: true
				passwordCharacter: "\u25CF"
				clip: true

				Text {
					text: "Password..."
					color: Colors.onSurfaceVariant
					font.pixelSize: 13
					visible: passwordInput.text === ""
					anchors.verticalCenter: parent.verticalCenter
				}

				Keys.onReturnPressed: submit()
			}
		}

		Row {
			spacing: 6
			Layout.alignment: Qt.AlignRight

			Rectangle {
				height: 28
				implicitWidth: 70
				radius: 6
				color: Colors.surfaceContainer

				Text {
					anchors.centerIn: parent
					text: "Cancel"
					color: Colors.onSurface
					font.pixelSize: 12
				}

				MouseArea {
					anchors.fill: parent
					onClicked: {
						polkit.cancelled()
						passwordInput.text = ""
					}
				}
			}

			Rectangle {
				height: 28
				implicitWidth: 90
				radius: 6
				color: Colors.primary

				Text {
					anchors.centerIn: parent
					text: "Authenticate"
					color: Colors.onPrimary
					font.pixelSize: 12
					font.weight: Font.Medium
				}

				MouseArea {
					anchors.fill: parent
					onClicked: submit()
				}
			}
		}
	}

	function submit() {
		if (passwordInput.text.length > 0) {
			polkit.authenticated(passwordInput.text)
			passwordInput.text = ""
		}
	}
}
