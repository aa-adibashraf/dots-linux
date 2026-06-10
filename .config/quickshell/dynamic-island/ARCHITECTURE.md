# Dynamic Island — Architecture & Implementation

A morphing dynamic island desktop shell built with [Quickshell](https://quickshell.outfoxxed.me) (Qt6/QML), replacing Waybar on Hyprland.

---

## Directory Layout

```
~/.config/quickshell/dynamic-island/
├── shell.qml                # Entry point
├── DynamicIsland.qml         # Main PanelWindow — state machine
├── config/
│   └── Colors.qml            # Singleton: live color scheme parser
├── services/
│   ├── Audio.qml             # Singleton: PipeWire sink controls
│   ├── MprisManager.qml     # Singleton: MPRIS media player bridge
│   └── NotificationDaemon.qml  # Singleton: notification server + history
└── components/
    ├── ControlCenter.qml     # Quick toggles, audio card, notification history
    ├── ThemePanel.qml        # Color scheme swatch viewer
    ├── SettingsPanel.qml     # System info, volume/brightness sliders, reload
    ├── PowerMenu.qml         # 6 power actions with hand-drawn vector icons
    ├── PolkitPrompt.qml      # Polkit authentication dialog
    ├── EqVisualizer.qml      # Animated audio EQ bars
    ├── ProgressBar.qml       # Pill-shaped progress bar
    ├── SpringAnimation.qml   # Critically damped spring animation
    ├── MediaIconButton.qml   # Clickable media control icon button
    └── VectorIcons/
        ├── SpeakerIcon.qml   # Multi-state speaker glyph
        ├── BrightnessIcon.qml  # Sun brightness glyph
        └── MediaIcons.qml    # Play/pause/prev/next glyphs
```

---

## Entry Point: `shell.qml`

The entry point creates a `ShellRoot` with `Variants` iterating over `Quickshell.screens` to support multi-monitor. Each screen gets its own `DynamicIsland` instance.

```qml
ShellRoot {
    Variants {
        model: Quickshell.screens
        DynamicIsland {
            property var modelData
            screen: modelData
        }
    }
}
```

- `QS_NO_RELOAD_POPUP` pragma suppresses the reload notification popup
- `ShellId` pragma sets a deterministic shell ID
- `settings.watchFiles: true` enables live QML reload on file save

---

## State Machine: `DynamicIsland.qml`

A `PanelWindow` (layershell surface) pinned to the top edge of the screen. The dimension and content are driven entirely by the `islandState` string property.

### Size Dimensions

| Property | Value | Used By |
|----------|-------|---------|
| `pillHeight` | 38px | idle, expanded, osd |
| `notifHeight` | 64px | notification |
| `tallHeight` | 500px | launcher, control, theme, settings |
| `powerHeight` | 200px | power menu |
| `polkitHeight` | 130px | polkit prompt |

### State Transitions

| State | Triggers | Size | Content |
|-------|----------|------|---------|
| `idle` | Default / Esc / right-click | ~130×38 | Clock + EQ visualizer |
| `expanded` | Hover enters pill area | 650×38 | Media controls + hero clock + system tray |
| `osd` | `showVolumeOSD()` / `showBrightnessOSD()` | 280×38 | Icon + progress bar + %, auto-dismiss 1.5s |
| `notification` | Incoming notification (DBus) | 420×64 | App icon + summary + body + countdown bar |
| `launcher` | External trigger | 500×500 | Search input + filtered results ListView |
| `control` | Click clock in `expanded` | 500×500 | Toggles + audio card + volume + notification history |
| `theme` | "Theme" button in control center | 500×500 | Scrollable color swatch list |
| `settings` | "Settings" button in control center | 500×500 | System info + sliders + reload button |
| `power` | Power icon in control center | 420×200 | 6 power action buttons |
| `polkit` | `showPolkit()` from polkit agent | 400×130 | Action description + password input |

### Window Behavior

- `WlrLayer.Top` — floats above all other windows
- `exclusiveZone: 0` — does not reserve space (overlays content)
- `color: "transparent"` — only the pill `Rectangle` is visible
- The pill `Rectangle` has `layer.enabled: true` with `MultiEffect` shadow for the drop shadow effect
- Width and height use `Behavior { SpringAnimation {} }` for smooth morphing
- A full-window `MouseArea` with `hoverEnabled: true` detects hover to expand/contract

### Hover Logic

```
onContainsMouseChanged:
  - OSD / notification states → return (don't interfere)
  - expanded / launcher / control / power / polkit / theme / settings → return (user is interacting)
  - containsMouse && !pinned → set state to "expanded"
  - !containsMouse && !pinned && state is "expanded" → set state to "idle"
```

Right-click anywhere dismisses to `idle` and unpins.

---

## Services

### `Colors.qml` — Live Color Scheme

A `Singleton` that reads `~/.config/hypr/scheme/current.conf` (a Catppuccin-style hyprland color file) via `FileView`. The file is watched for changes — when it changes, the scheme is re-parsed and all bindings update reactively.

Parsing: lines matching `$name=XXXXXX` (6-char hex) are extracted and stored in a `values` map with a `#` prefix. The singleton exposes 80+ themed color properties (Material You + catppuccin flavors) with hardcoded fallbacks.

### `Audio.qml` — PipeWire Sink Singleton

Wraps `Pipewire.defaultAudioSink` into a reactive singleton:

- `volume` (0.0–1.0), `volumePercent` (0–100), `muted`, `sinkName`
- `setVolume(v)` — sets sink volume
- `toggleMute()` — toggles mute
- Uses `PwObjectTracker` to keep the sink reference alive (required by PipeWire API)

### `MprisManager.qml` — MPRIS Bridge

A singleton exposing the first available MPRIS player:

- `players`, `activePlayer`, `hasPlayer`
- `isPlaying`, `isPaused`
- `trackTitle`, `artist`, `album`, `artUrl`, `playerName`
- `trackLength`, `position` — for progress bar

### `NotificationDaemon.qml` — Notification Server

Implements a `NotificationServer` from Quickshell's notification service:

- Captures incoming `onNotification` signals and stores them in `notificationHistory` (capped at 50 entries)
- If `dndEnabled` is false, sets `currentNotification` (triggers popup via `Connections` in `DynamicIsland.qml`)
- `dismissCurrent()` — dismisses the current notification
- `clearHistory()` / `removeHistory(index)` — manages history
- `toggleDnd()` — toggles do-not-disturb

---

## Components

### ControlCenter.qml

A `ColumnLayout` with:

1. **Quick Toggles Grid** (2 rows × 4 columns)
   - DND — toggles `NotificationDaemon.dndEnabled`, highlights with `primaryContainer`
   - Mute — toggles `Audio.toggleMute()`, highlights with `errorContainer`
   - Snip — runs `grim` + `slurp` screenshot-to-clipboard
   - Lock — launches `hyprlock`
   - Theme — emits `themeRequested()` signal
   - Settings — emits `settingsRequested()` signal

2. **Audio Card** — Album art (56×56 rounded rect with fallback music note), track title, artist, album, position progress bar, play/pause/prev/next controls

3. **Volume Slider** — Custom bar with speaker icon, click-to-seek, draggable

4. **Notification History** — Header with "Clear All" and power menu icon (hand-drawn arrow), scrollable `ListView` of past notifications with relative timestamps, click-to-dismiss individual entries

### ThemePanel.qml

Displays 22 color swatches from the `Colors` singleton in a scrollable list. Each row shows a colored rectangle, the label, and the hex value. Uses `Flickable` for scrolling.

### SettingsPanel.qml

Uses `Process` objects (from `Quickshell.Io`) to fetch system info:

- **System Info Card** — hostname, kernel version, uptime (via `hostname`, `uname -r`, `/proc/uptime` with awk)
- **Volume Slider** — same as control center
- **Brightness Slider** — reads/writes via `brightnessctl`, click-to-set
- **Reload Configuration Button** — calls `Quickshell.restart()` to reload all QML

### PowerMenu.qml

6 action buttons in a 3×2 `GridLayout`:

| Action | Icon | Command |
|--------|------|---------|
| Lock | Lock shape | `loginctl lock-session` |
| Sleep | Zzz moon | `systemctl suspend` |
| Hibernate | Double bar | `systemctl hibernate` |
| Reboot | Circular arrows | `systemctl reboot` |
| Shutdown | Power circle | `systemctl poweroff` |
| Logout | Door arrow | `hyprctl dispatch exit` |

Each icon is hand-drawn with `Shape { ShapePath { ... } }` — zero font icons. Shutdown icon uses `Colors.error` for visual distinction. Hover highlights the button background.

### PolkitPrompt.qml

Displays the polkit action description, a masked password `TextInput`, and Submit/Cancel buttons. Uses `Quickshell.Services.Polkit.AuthFlow` for authentication. Emits `authenticated(password)` or `cancelled()` signals. Includes an info icon drawn with `Shape`.

### EqVisualizer.qml

4 animated bars that bounce randomly when `active` is true (bound to `MprisManager.isPlaying`). Uses a `Timer` (90ms interval) to randomize bar heights (4–20px). Opacity fades on inactive with `Behavior on opacity`.

### ProgressBar.qml

Generic progress bar with:
- `value` (0.0–1.0)
- `accentColor`
- `barHeight`
- Spring-animated width transitions
- Semi-transparent background track

### SpringAnimation.qml

A pre-configured `SpringAnimation`:
- `spring: 5`, `damping: 1.0` (critically damped — no overshoot)
- `epsilon: 0.001`, `mass: 1.0`

### Vector Icons

All icons are pure `Shape { ShapePath { ... } }` — no font icons, no SVG files:

- **SpeakerIcon.qml** — Reactive speaker glyph with 3 states: muted (X), low (1 bar), high (3 bars). The bar count is driven by the `level` property (0–100).
- **BrightnessIcon.qml** — Sun with rays
- **MediaIcons.qml** — Provides `play`, `pause`, `prev`, `next` path data
- **MediaIconButton.qml** — Wraps a `MouseArea` + `Shape` into a reusable clickable icon button with press feedback and configurable size/color

---

## Key Design Decisions

### Zero Font Icons
Every glyph is hand-drawn using Qt Quick's `Shape` + `Path*` primitives. There are zero font icon dependencies. This ensures consistency regardless of font configuration and avoids icon font licensing issues.

### Color System
All colors come from the `Colors` singleton, which reads the same `current.conf` file used by Hyprland's decoration colors. This means theme changes (via wallust, pywal, etc.) are reflected live without restarting the shell. The singleton provides Material You semantic colors (primary, secondary, tertiary, error, surface, etc.) plus catppuccin palette colors and convenience aliases (text, base, mantle, etc.).

### Spring Animations
All morphing transitions use a critically damped spring (`damping=1.0`) for smooth, overshoot-free motion. This applies to pill width/height, progress bar fills, and EQ bar heights.

### Multi-Monitor
Each screen gets its own `DynamicIsland` instance via the `Variants { model: Quickshell.screens }` pattern. All monitors show the same content simultaneously.

### State Encapsulation
Rather than using QML `State` elements, the project uses a flat `islandState` string property and `visible:` bindings on each content block. This was chosen for clarity — each state's content is defined inline in `DynamicIsland.qml` with clear visibility conditions, making the state machine explicit and easy to modify.

### Process Management
Commands are launched via Quickshell's `Process { }` QML type (from `Quickshell.Io`). Each one-shot process gets its own `Process` instance with `StdioCollector` for reading stdout. The `.exec()` instance method is used (not a static call), following the Quickshell 0.3.0 API.

---

## Running

```bash
# By config name
quickshell --config dynamic-island

# With auto-reload on file changes (already enabled in shell.qml)
# Just save any .qml file and it reloads automatically
```

## Entry Flow

1. `shell.qml` creates a `DynamicIsland` per screen
2. On load, `DynamicIsland.qml` creates the pill in `idle` state showing the clock and EQ visualizer
3. Hover over the pill → transitions to `expanded` (media controls + hero clock + system tray)
4. Click the clock → transitions to `control` (control center with toggles, audio, notifications)
5. From control center: theme, settings, and power buttons navigate to their respective panels
6. Incoming notifications → `notification` state with countdown
7. Volume/brightness keys → `osd` state with progress bar (auto-dismiss after 1.5s)
8. Right-click anywhere → dismiss back to `idle`
