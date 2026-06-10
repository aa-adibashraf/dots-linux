import Quickshell
import Quickshell.Services.Notifications
import QtQml

Singleton {
	id: daemon

	readonly property NotificationServer notifServer: NotificationServer {
		imageSupported: true
		bodySupported: true
		bodyMarkupSupported: false
		onNotification: function(notification) {
			notification.tracked = true

			var entry = {
				appName: notification.appName,
				summary: notification.summary,
				body: notification.body,
				appIcon: notification.appIcon,
				urgency: notification.urgency,
				time: new Date()
			}
			daemon.notificationHistory.push(entry)
			daemon.notificationHistory = daemon.notificationHistory.slice()

			if (daemon.notificationHistory.length > 50) {
				daemon.notificationHistory.shift()
			}

			if (!daemon.dndEnabled) {
				daemon.currentNotification = notification
			}
		}
	}

	property Notification currentNotification: null
	property var notificationHistory: []
	property bool dndEnabled: false

	onCurrentNotificationChanged: {
		if (currentNotification) {
			currentNotification.closed.connect(function() {
				daemon.currentNotification = null
			})
		}
	}

	function dismissCurrent() {
		if (daemon.currentNotification) {
			daemon.currentNotification.dismiss()
			daemon.currentNotification = null
		}
	}

	function toggleDnd() {
		daemon.dndEnabled = !daemon.dndEnabled
	}

	function clearHistory() {
		daemon.notificationHistory = []
	}

	function removeHistory(index) {
		daemon.notificationHistory.splice(index, 1)
		daemon.notificationHistory = daemon.notificationHistory.slice()
	}
}
