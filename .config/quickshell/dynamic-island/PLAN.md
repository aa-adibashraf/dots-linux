# Dynamic Island — Quickshell Desktop Shell

A morphing "Dynamic Island" style desktop panel, built with Quickshell (Qt6/QML), replacing Waybar on Omarchy/Hyprland.

## Architecture

```
~/.config/quickshell/dynamic-island/
├── shell.qml                    # Entry point: ShellRoot + multi-monitor Variants
├── DynamicIsland.qml             # Main PanelWindow: state machine managing all 10 states
├── PLAN.md                      # This file
├── bin/
│   └── toggle-bar.sh            # Toggle between Waybar and Quickshell
├── config/
│   └── Colors.qml               # Singleton: parses hypr/scheme/current.conf
├── services/
│   ├── Audio.qml                # Singleton: PipeWire sink/volume/mute
│   ├── MprisManager.qml         # Singleton: MPRIS players + playback
│   ├── NotificationDaemon.qml   # Singleton: NotificationServer + history
│   ├── Power.qml                # Singleton: systemctl wrappers
│   └── ThemeEngine.qml          # Singleton: wallust + wallpaper switch
├── components/
│   ├── SpringAnimation.qml      # Critically damped spring (damping=1.0)
│   ├── EqVisualizer.qml         # Animated audio EQ bars for MPRIS
│   ├── ProgressBar.qml          # Pill-shaped progress track
│   ├── SystemTrayHost.qml       # StatusNotifierItem integration
│   └── VectorIcons/             # Hand-drawn QML vector icons (NO font icons)
│       ├── BatteryIcon.qml
│       ├── WifiIcon.qml
│       ├── SpeakerIcon.qml
│       ├── BrightnessIcon.qml
│       ├── MediaIcons.qml
│       └── PowerIcons.qml
└── states/
    ├── IdlePill.qml             # State 1: time + EQ visualizer
    ├── ExpandedPill.qml         # State 2: media/clock/tray
    ├── OSDMode.qml              # State 3: volume/brightness
    ├── ToastNotification.qml    # State 4: notification banner
    ├── AppLauncher.qml          # State 5: search/calc/clipboard
    ├── ControlCenter.qml        # State 6: quick settings/audio/history
    ├── ThemePalette.qml         # State 7: color swatches/wallpapers
    ├── SettingsPanel.qml        # State 8: bar/font sliders
    ├── PowerOperations.qml      # State 9: lock/suspend/logout/reboot/shutdown
    └── PolkitDialog.qml         # State 10: auth agent
```

## 10 States Overview

| # | State | Trigger | Size | Key Content |
|---|-------|---------|------|-------------|
| 1 | Idle Pill | Default | ~120x36 | HH:MM clock, MPRIS EQ bars |
| 2 | Expanded Pill | Hover / Pin | ~600-800x36 | Media controls, hero clock, tray |
| 3 | OSD Mode | Vol/Bright keys | ~250x36 | Progress bar, percentage, auto-dismiss 1.5s |
| 4 | Toast Notifications | DBus signal | ~400x64 | Icon, summary, body, countdown timer |
| 5 | App Launcher | Alt+D | ~400x~400 | Search input, results, calc/clipboard modes |
| 6 | Control Center | Alt+A | ~500x~500 | Quick toggles, audio card, notif history |
| 7 | Theme/Wallpaper | Alt+T / Alt+Shift+T | ~500x~500 | 18 color swatches or wallpaper grid |
| 8 | Settings Panel | Alt+, | ~400x~300 | Bar height, font size sliders |
| 9 | Power Operations | Ctrl+Alt+Del | ~400x60 | 5 buttons, 2-step for destructive |
| 10 | Polkit Agent | pkexec | ~400x200 | Action info, password input |

## Implementation Phases

### Phase 1 — Foundation (DONE)
- Install quickshell
- Create directory structure
- `shell.qml` entry point with multi-monitor Variants
- `config/Colors.qml` singleton (parses `hypr/scheme/current.conf`)
- `components/SpringAnimation.qml`
- `bin/toggle-bar.sh` — toggle between Waybar and Quickshell
- Verify: `qs -p ~/.config/quickshell/dynamic-island/` shows visible panel

### Phase 2 — Idle Pill (State 1)
- `SystemClock` → formatted time text
- Centered pill with rounded corners and drop shadow
- `MprisManager` → EQ visualizer bars when music plays
- EQ bars fade out on pause

### Phase 3 — Expanded Pill (State 2)
- Three-zone layout: media left, clock center, tray right
- Hover detection → morph from IdlePill
- Pin/unpin via click on empty space
- SystemTrayHost via `Quickshell.Services.SystemTray`
- MPRIS playback controls (Play/Pause, Prev, Next)
- Hero clock with full date

### Phase 4 — OSD Mode (State 3)
- `services/Audio.qml` (PipeWire sink singleton)
- Volume progress bar with speaker glyph
- Brightness via `omarchy brightness display`
- Reactive speaker icon (0%, 1-49%, 50-100%)
- Auto-dismiss Timer (1500ms)

### Phase 5 — Notifications (State 4)
- `NotificationDaemon.qml` (NotificationServer + history)
- Toast banner: avatar/icon, summary, body
- Animated countdown progress bar
- Hover-pause, click-dismiss
- Critical alerts → red accent + longer timeout
- DND mode → suppress popup, log to history

### Phase 6 — App Launcher (State 5)
- TextInput + ListView results
- `DesktopEntries` integration
- Prefix: `=` → JS calculator → `wl-copy`
- Prefix: `:` → `cliphist` clipboard manager
- Arrow key nav, Enter to execute, Esc to dismiss

### Phase 7 — Control Center (State 6)
- Quick settings grid (WiFi, Audio, BT, DND, Nightlight)
- Split-target: icon toggles, text opens subview
- Audio card: blurred album art + player controls
- Notification history with "Clear All"

### Phase 8 — Theme & Wallpaper (State 7)
- 18 color swatches from scheme file
- Click → `wallust` color injection
- Wallpaper thumbnail grid via `ScreencopyView`

### Phase 9 — Settings Panel (State 8)
- Sliders for: bar height (30-51px), font size
- Real-time preview on drag

### Phase 10 — Power Operations (State 9)
- 5 buttons: Lock, Suspend, Logout, Reboot, Power Off
- Safe actions (Lock/Suspend) = single click
- Destructive (Reboot/Shutdown) = two-click with red confirm

### Phase 11 — Polkit Agent (State 10)
- `PolkitAgent` integration
- Action details display
- Masked password input
- Esc/click-outside → cancel

### Phase 12 — Migration & Polish
- Replace Waybar in Hyprland autostart
- Add non-conflicting keybindings
- Port remaining Waybar indicators (weather, updates, voxtype, etc.)
- Multi-monitor testing
- Performance optimization

## Global Directives

- **Zero font icons**: Every glyph hand-drawn with `Shape` + `Path*` primitives
- **iOS battery cell**: Percentage text inside custom outline; charging bolt + green fill
- **Multi-monitor**: `Variants { model: Quickshell.screens }` pattern; OSD/notifications on focused monitor only
- **Spring animations**: Critically damped (damping=1.0), zero overshoot
- **Color system**: Reads `~/.config/hypr/scheme/current.conf` live via `FileView`

## Toggle Mechanism

Use `bin/toggle-bar.sh` to switch between Waybar and Quickshell:

```bash
~/.config/quickshell/dynamic-island/bin/toggle-bar.sh
```

This kills the current bar and starts the other. Can be bound to a key for quick switching during development.

## Running

```bash
# By path (development)
qs -p ~/.config/quickshell/dynamic-island/

# By config name (auto-detected as subdirectory)
qs -c dynamic-island

# Auto-start in autostart.conf:
# exec-once = uwsm-app -- qs -c dynamic-island
```
