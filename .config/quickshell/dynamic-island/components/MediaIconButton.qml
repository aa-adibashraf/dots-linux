import QtQuick
import "VectorIcons"

Item {
	id: root

	property string iconType: "play"
	property color iconColor: Colors.onSurface
	property real size: 14

	signal clicked()

	implicitWidth: size + hoverPadding * 2
	implicitHeight: size + hoverPadding * 2

	readonly property real hoverPadding: 6

	Rectangle {
		id: bg
		anchors.fill: parent
		radius: 6
		color: root.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
		Behavior on color { ColorAnimation { duration: 150 } }
	}

	MediaIcons {
		iconType: root.iconType
		iconColor: root.iconColor
		anchors.centerIn: parent
		implicitWidth: root.size
		implicitHeight: root.size
	}

	readonly property bool hovered: hoverArea.containsMouse

	MouseArea {
		id: hoverArea
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		onClicked: root.clicked()
	}
}
