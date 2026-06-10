import QtQuick
import QtQuick.Shapes

Item {
	id: root

	property int level: 100
	property color iconColor: Colors.onSurface

	implicitWidth: 16
	implicitHeight: 16

	readonly property bool isMuted: level <= 0

	Shape {
		anchors.fill: parent
		antialiasing: true
		ShapePath {
			strokeColor: "transparent"
			fillColor: root.iconColor
			joinStyle: ShapePath.RoundJoin

			PathMove { x: 5; y: 4 }
			PathLine { x: 8; y: 4 }
			PathLine { x: 12; y: 1 }
			PathLine { x: 12; y: 15 }
			PathLine { x: 8; y: 12 }
			PathLine { x: 5; y: 12 }
			PathLine { x: 5; y: 4 }
		}
	}

	Shape {
		anchors.fill: parent
		antialiasing: true
		visible: !root.isMuted
		ShapePath {
			strokeColor: root.iconColor
			strokeWidth: 1.5
			fillColor: "transparent"
			capStyle: ShapePath.RoundCap

			PathMove { x: 13.5; y: 5.5 }
			PathLine { x: 13.5; y: 10.5 }
		}
	}

	Shape {
		anchors.fill: parent
		antialiasing: true
		visible: !root.isMuted && root.level > 30
		ShapePath {
			strokeColor: root.iconColor
			strokeWidth: 1.5
			fillColor: "transparent"
			capStyle: ShapePath.RoundCap

			PathMove { x: 15; y: 3.5 }
			PathLine { x: 15; y: 12.5 }
		}
	}

	Shape {
		anchors.fill: parent
		antialiasing: true
		visible: root.isMuted
		ShapePath {
			strokeColor: root.iconColor
			strokeWidth: 1.5
			fillColor: "transparent"
			capStyle: ShapePath.RoundCap

			PathMove { x: 10; y: 5 }
			PathLine { x: 14; y: 11 }
			PathMove { x: 14; y: 5 }
			PathLine { x: 10; y: 11 }
		}
	}
}
