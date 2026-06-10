import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import "../config"

Item {
	id: powerMenu
	clip: true

	property var actions: [
		{ label: "Lock", icon: "lock", cmd: ["loginctl", "lock-session"] },
		{ label: "Sleep", icon: "sleep", cmd: ["systemctl", "suspend"] },
		{ label: "Hibernate", icon: "hibernate", cmd: ["systemctl", "hibernate"] },
		{ label: "Reboot", icon: "reboot", cmd: ["systemctl", "reboot"] },
		{ label: "Shutdown", icon: "shutdown", cmd: ["systemctl", "poweroff"] },
		{ label: "Logout", icon: "logout", cmd: ["hyprctl", "dispatch", "exit"] }
	]

	GridLayout {
		anchors.fill: parent
		anchors.margins: 10
		columns: 3
		columnSpacing: 8
		rowSpacing: 8

		Repeater {
			model: powerMenu.actions

			delegate: Item {
				Layout.fillWidth: true
				Layout.fillHeight: true

				Rectangle {
					id: btnBg
					anchors.fill: parent
					radius: 10
					color: Colors.surfaceVariant

					Column {
						anchors.centerIn: parent
						spacing: 6

						Item {
							width: 32
							height: 32
							anchors.horizontalCenter: parent.horizontalCenter

							Shape {
								anchors.fill: parent
								antialiasing: true
								visible: modelData.icon === "lock"
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									joinStyle: ShapePath.RoundJoin
									PathMove { x: 8; y: 14 }
									PathLine { x: 8; y: 7 }
									PathLine { x: 10; y: 5 }
									PathLine { x: 22; y: 5 }
									PathLine { x: 24; y: 7 }
									PathLine { x: 24; y: 14 }
									PathLine { x: 8; y: 14 }
								}
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 10; y: 14 }
									PathLine { x: 10; y: 24 }
									PathLine { x: 22; y: 24 }
									PathLine { x: 22; y: 14 }
									PathLine { x: 10; y: 14 }
								}
								ShapePath {
									strokeColor: Colors.surfaceVariant
									strokeWidth: 1.5
									fillColor: "transparent"
									PathMove { x: 16; y: 17 }
									PathLine { x: 16; y: 21 }
								}
							}

							Shape {
								anchors.fill: parent
								antialiasing: true
								visible: modelData.icon === "sleep"
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 10; y: 26 }
									PathLine { x: 26; y: 26 }
									PathLine { x: 26; y: 18 }
									PathLine { x: 14; y: 26 }
									PathLine { x: 22; y: 18 }
									PathLine { x: 22; y: 10 }
									PathLine { x: 10; y: 18 }
									PathLine { x: 18; y: 10 }
									PathLine { x: 18; y: 6 }
									PathLine { x: 8; y: 14 }
									PathLine { x: 14; y: 8 }
									PathLine { x: 10; y: 8 }
									PathLine { x: 10; y: 26 }
								}
							}

							Shape {
								anchors.fill: parent
								antialiasing: true
								visible: modelData.icon === "hibernate"
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 8; y: 26 }
									PathLine { x: 14; y: 26 }
									PathLine { x: 14; y: 6 }
									PathLine { x: 8; y: 6 }
									PathLine { x: 8; y: 26 }
								}
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 18; y: 26 }
									PathLine { x: 24; y: 26 }
									PathLine { x: 24; y: 6 }
									PathLine { x: 18; y: 6 }
									PathLine { x: 18; y: 26 }
								}
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 11; y: 14 }
									PathLine { x: 21; y: 14 }
									PathLine { x: 21; y: 18 }
									PathLine { x: 11; y: 18 }
									PathLine { x: 11; y: 14 }
								}
							}

							Shape {
								anchors.fill: parent
								antialiasing: true
								visible: modelData.icon === "reboot"
								ShapePath {
									strokeColor: Colors.primary
									strokeWidth: 2.5
									fillColor: "transparent"
									capStyle: ShapePath.RoundCap
									PathMove { x: 10; y: 8 }
									PathLine { x: 22; y: 16 }
									PathMove { x: 22; y: 8 }
									PathLine { x: 10; y: 16 }
								}
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 22; y: 8 }
									PathLine { x: 26; y: 16 }
									PathLine { x: 18; y: 14 }
									PathLine { x: 22; y: 8 }
								}
							}

							Shape {
								anchors.fill: parent
								antialiasing: true
								visible: modelData.icon === "shutdown"
								ShapePath {
									strokeColor: Colors.error
									strokeWidth: 2.5
									fillColor: "transparent"
									capStyle: ShapePath.RoundCap
									PathMove { x: 16; y: 4 }
									PathLine { x: 16; y: 17 }
								}
								ShapePath {
									strokeColor: Colors.error
									strokeWidth: 2.5
									fillColor: "transparent"
									capStyle: ShapePath.RoundCap
									PathMove { x: 9; y: 16 }
									PathLine { x: 23; y: 16 }
									PathMove { x: 16; y: 9 }
									PathLine { x: 16; y: 23 }
								}
							}

							Shape {
								anchors.fill: parent
								antialiasing: true
								visible: modelData.icon === "logout"
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 6; y: 8 }
									PathLine { x: 6; y: 24 }
									PathLine { x: 18; y: 24 }
									PathLine { x: 18; y: 20 }
									PathLine { x: 14; y: 20 }
									PathLine { x: 14; y: 22 }
									PathLine { x: 8; y: 22 }
									PathLine { x: 8; y: 10 }
									PathLine { x: 14; y: 10 }
									PathLine { x: 14; y: 12 }
									PathLine { x: 18; y: 12 }
									PathLine { x: 18; y: 8 }
									PathLine { x: 6; y: 8 }
								}
								ShapePath {
									strokeColor: "transparent"
									fillColor: Colors.primary
									PathMove { x: 20; y: 12 }
									PathLine { x: 26; y: 16 }
									PathLine { x: 20; y: 20 }
									PathLine { x: 20; y: 17 }
									PathLine { x: 13; y: 17 }
									PathLine { x: 13; y: 15 }
									PathLine { x: 20; y: 15 }
									PathLine { x: 20; y: 12 }
								}
							}
						}

						Text {
							text: modelData.label
							color: Colors.onSurface
							font.pixelSize: 12
							font.weight: Font.Medium
							anchors.horizontalCenter: parent.horizontalCenter
						}
					}
				}

				MouseArea {
					anchors.fill: parent
					hoverEnabled: true
					onEntered: btnBg.color = Colors.surfaceContainer
					onExited: btnBg.color = Colors.surfaceVariant
					onClicked: Process.exec(modelData.cmd[0], modelData.cmd.slice(1))
				}
			}
		}
	}
}
