import QtQuick
import QtQuick.Layouts
import "../config"

Item {
	id: themePanel
	clip: true

	property var swatches: [
		{ label: "Primary", color: Colors.primary },
		{ label: "onPrimary", color: Colors.onPrimary },
		{ label: "Primary Container", color: Colors.primaryContainer },
		{ label: "Secondary", color: Colors.secondary },
		{ label: "onSecondary", color: Colors.onSecondary },
		{ label: "Secondary Container", color: Colors.secondaryContainer },
		{ label: "Tertiary", color: Colors.tertiary },
		{ label: "onTertiary", color: Colors.onTertiary },
		{ label: "Tertiary Container", color: Colors.tertiaryContainer },
		{ label: "Error", color: Colors.error },
		{ label: "onError", color: Colors.onError },
		{ label: "Error Container", color: Colors.errorContainer },
		{ label: "Success", color: Colors.success },
		{ label: "onSuccess", color: Colors.onSuccess },
		{ label: "Surface", color: Colors.surface },
		{ label: "onSurface", color: Colors.onSurface },
		{ label: "Surface Variant", color: Colors.surfaceVariant },
		{ label: "onSurfaceVariant", color: Colors.onSurfaceVariant },
		{ label: "Background", color: Colors.background },
		{ label: "onBackground", color: Colors.onBackground },
		{ label: "Outline", color: Colors.outline },
		{ label: "Outline Variant", color: Colors.outlineVariant }
	]

	ColumnLayout {
		anchors.fill: parent
		spacing: 6

		Text {
			text: "Color Scheme"
			color: Colors.onSurface
			font.pixelSize: 14
			font.weight: Font.Bold
			Layout.topMargin: 4
		}

		Flickable {
			Layout.fillWidth: true
			Layout.fillHeight: true
			clip: true
			contentHeight: swatchColumn.height

			Column {
				id: swatchColumn
				width: parent.width
				spacing: 3

				Repeater {
					model: themePanel.swatches

					Rectangle {
						width: parent.width
						height: 30
						radius: 6
						color: Colors.surfaceVariant

						Row {
							anchors.fill: parent
							anchors.leftMargin: 8
							anchors.rightMargin: 8
							spacing: 8

							Rectangle {
								width: 16; height: 16
								radius: 4
								color: modelData.color
								border.color: Colors.outlineVariant
								border.width: 1
								anchors.verticalCenter: parent.verticalCenter
							}

							Text {
								text: modelData.label
								color: Colors.onSurface
								font.pixelSize: 11
								anchors.verticalCenter: parent.verticalCenter
							}

							Item {
								width: parent.width - 16 - 90 - 16
								height: 1
								anchors.verticalCenter: parent.verticalCenter
							}

							Text {
								text: modelData.color
								color: Colors.onSurfaceVariant
								font.pixelSize: 10
								font.weight: Font.Medium
								anchors.verticalCenter: parent.verticalCenter
							}
						}
					}
				}
			}
		}
	}
}
