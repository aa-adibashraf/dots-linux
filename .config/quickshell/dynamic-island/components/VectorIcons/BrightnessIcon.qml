import QtQuick
import QtQuick.Shapes

Item {
	id: root

	property color iconColor: Colors.onSurface

	implicitWidth: 16
	implicitHeight: 16

	Rectangle {
		x: parent.width / 2 - 2.5
		y: parent.height / 2 - 2.5
		width: 5
		height: 5
		radius: 2.5
		color: root.iconColor
	}

	Repeater {
		model: [
			{ x1: 8, y1: 1, x2: 8, y2: 3 },
			{ x1: 8, y1: 13, x2: 8, y2: 15 },
			{ x1: 1, y1: 8, x2: 3, y2: 8 },
			{ x1: 13, y1: 8, x2: 15, y2: 8 },
		]

		Rectangle {
			x: modelData.x1 - 0.5
			y: modelData.y1
			width: 1
			height: 2
			color: root.iconColor
		}
	}

	Repeater {
		model: [
			{ x1: 2.5, y1: 2.5, x2: 4, y2: 4 },
			{ x1: 12, y1: 2.5, x2: 13.5, y2: 4 },
			{ x1: 2.5, y1: 13.5, x2: 4, y2: 12 },
			{ x1: 12, y1: 13.5, x2: 13.5, y2: 12 },
		]

		Rectangle {
			x: modelData.x1
			y: modelData.y1
			width: 1
			height: 1
			color: root.iconColor
		}
	}
}
