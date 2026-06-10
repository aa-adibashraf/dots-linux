#!/bin/bash
# Toggle between Waybar and Quickshell Dynamic Island
# Usage: toggle-bar.sh [waybar|quickshell]
# Can be bound to a key for easy switching during development

QS_DIR="$HOME/.config/quickshell/dynamic-island"

case "${1:-}" in
	waybar)
		pkill -f "quickshell.*dynamic-island" 2>/dev/null || true
		sleep 0.3
		if ! pgrep -x waybar >/dev/null 2>&1; then
			uwsm-app -- waybar >/dev/null 2>&1 &
			notify-send -t 2000 "Bar" "Switched to Waybar"
		fi
		;;
	quickshell)
		pkill -x waybar 2>/dev/null || true
		sleep 0.3
		if ! pgrep -f "quickshell.*dynamic-island" >/dev/null 2>&1; then
			uwsm-app -- qs -d -p "$QS_DIR" &
			notify-send -t 2000 "Bar" "Switched to Dynamic Island"
		fi
		;;
	*)
		if pgrep -f "quickshell.*dynamic-island" >/dev/null 2>&1; then
			exec "$0" waybar
		else
			exec "$0" quickshell
		fi
		;;
esac
