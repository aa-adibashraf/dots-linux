import QtQuick

Item {
	id: root

	property real value: 0.0
	property color accentColor: "#ffffff"
	property real barHeight: 6

	implicitWidth: 120
	implicitHeight: barHeight

	Rectangle {
		anchors.fill: parent
		radius: barHeight / 2
		color: Qt.rgba(1, 1, 1, 0.15)
	}

	Rectangle {
		width: parent.width * root.value
		height: parent.height
		radius: barHeight / 2
		color: root.accentColor

		Behavior on width {
			SpringAnimation {}
		}
	}
}
