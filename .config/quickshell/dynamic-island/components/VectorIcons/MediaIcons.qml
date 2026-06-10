import QtQuick
import QtQuick.Shapes

Item {
	id: root

	property string iconType: "play"
	property color iconColor: Colors.onSurface

	implicitWidth: 14
	implicitHeight: 14

	Item {
		anchors.fill: parent
		visible: root.iconType === "play"

		Shape {
			anchors.fill: parent
			antialiasing: true
			ShapePath {
				strokeColor: "transparent"
				fillColor: root.iconColor
				joinStyle: ShapePath.RoundJoin

				PathMove { x: 2; y: 1 }
				PathLine { x: parent.width - 1; y: parent.height / 2 }
				PathLine { x: 2; y: parent.height - 1 }
				PathLine { x: 2; y: 1 }
			}
		}
	}

	Item {
		anchors.fill: parent
		visible: root.iconType === "pause"

		Rectangle {
			x: 2; width: 4; height: parent.height; radius: 1
			color: root.iconColor
		}
		Rectangle {
			x: parent.width - 6; width: 4; height: parent.height; radius: 1
			color: root.iconColor
		}
	}

	Item {
		anchors.fill: parent
		visible: root.iconType === "prev"

		Rectangle {
			x: 2; width: 2; height: parent.height; radius: 0.5
			color: root.iconColor
		}
		Shape {
			x: 6; width: parent.width - 6; height: parent.height
			antialiasing: true
			ShapePath {
				strokeColor: "transparent"
				fillColor: root.iconColor
				joinStyle: ShapePath.RoundJoin

				PathMove { x: 0; y: 1 }
				PathLine { x: parent.width; y: parent.height / 2 }
				PathLine { x: 0; y: parent.height - 1 }
				PathLine { x: 0; y: 1 }
			}
		}
	}

	Item {
		anchors.fill: parent
		visible: root.iconType === "next"

		Shape {
			width: parent.width - 4; height: parent.height
			antialiasing: true
			ShapePath {
				strokeColor: "transparent"
				fillColor: root.iconColor
				joinStyle: ShapePath.RoundJoin

				PathMove { x: 0; y: 1 }
				PathLine { x: parent.width; y: parent.height / 2 }
				PathLine { x: 0; y: parent.height - 1 }
				PathLine { x: 0; y: 1 }
			}
		}
		Rectangle {
			x: parent.width - 2; width: 2; height: parent.height; radius: 0.5
			color: root.iconColor
		}
	}
}
