import QtQuick
import qs.config

Item {
	id: root

	property bool active: false
	property color barColor: Colors.primary

	implicitWidth: childrenRect.width
	implicitHeight: 20

	visible: active
	opacity: active ? 1.0 : 0.0
	enabled: active

	Behavior on opacity { NumberAnimation { duration: 150 } }

	Row {
		spacing: 3
		anchors.verticalCenter: parent.verticalCenter

		Repeater {
			id: bars
			model: 4

			Rectangle {
				width: 3
				height: 4
				radius: 1.5
				color: root.barColor
				antialiasing: true

				Behavior on height { SpringAnimation { spring: 3; damping: 0.8; velocity: 0 } }
			}
		}
	}

	Timer {
		interval: 90
		running: root.active
		repeat: true
		onTriggered: {
			for (var i = 0; i < bars.count; i++) {
				var bar = bars.itemAt(i)
				if (bar) bar.height = 4 + Math.random() * 16
			}
		}
	}
}
