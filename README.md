# Altar – macOS Menu Bar Pomodoro App

## V2

- Timer tick bug fixed (no more double-speed countdown)
- Compact popover window (smaller footprint)
- Tasks tab is now optional — off by default, toggle it on in Settings
- Auto-start next session is off by default — timer stops at 00:00 and waits for you
- Reports now include a daily bar chart showing focus minutes per day
- Settings redesigned with all toggles in one place

---

Altar is a native macOS menu bar Pomodoro / focus timer. It lets you:

- Run a configurable Pomodoro-style focus timer from the macOS menu bar
- Track focus time against simple tasks (optional)
- See reports of your focus time with a daily bar chart

Everything runs locally on your Mac; there is no sync or app/website blocking.

## Features

- **Menu bar timer**
  - Lives in the macOS menu bar as a time label (e.g. `25:00`)
  - One click opens a compact popover UI
  - Quick Quit button in the popover

- **Pomodoro timer**
  - Focus, short break, and long break sessions
  - Configurable durations and long-break frequency
  - Auto-start next session (toggleable, off by default)
  - Skip and reset actions
  - Stops at 00:00 when auto-start is off so you control transitions
  - Local notification when a session or break completes

- **Tasks** (optional, enable in Settings)
  - Add lightweight tasks with a title
  - Mark tasks complete, delete when done
  - See how many Pomodoro sessions have been completed per task
  - Associate the current focus session with a task

- **Reports**
  - View total focus time and completed focus sessions (Today / This Week)
  - Daily bar chart showing focus minutes per day
  - Per-task breakdown when tasks are enabled

- **Settings**
  - Focus, short break, long break durations
  - Long break frequency
  - Auto-start next session toggle
  - Show/hide Tasks tab toggle
  - Reset to defaults

## Project structure

- `Altar.xcodeproj` – Xcode project (open in Xcode)
- `Altar/` – App source:
  - `AltarApp.swift` – SwiftUI `@main` entry and `NSApplicationDelegate`
  - `Info.plist` – bundle config (`LSUIElement` = menu bar only)
  - `Assets.xcassets` – asset catalog
  - `Models/` – `TimerSettings.swift`, `Task.swift`, `SessionHistory.swift`
  - `Services/` – `PersistenceService.swift`, `NotificationService.swift`, `SettingsManager.swift`
  - `ViewModels/` – `TaskStore.swift`, `HistoryStore.swift`, `TimerViewModel.swift`
  - `Views/` – `MenuBarContentView.swift`, `TimerView.swift`, `TaskListView.swift`, `ReportsView.swift`, `SettingsView.swift`
  - `StatusItemController.swift` – AppKit status item and SwiftUI popover host

## Requirements

- macOS 14.0 or later
- Xcode (tested with Xcode 16+)

## Running the app

1. Open `Altar.xcodeproj` in Xcode.
2. Select the `Altar` scheme and **My Mac** as the run destination.
3. Press **⌘R** to build and run.

On first launch:

- The app appears **only in the menu bar** (no Dock icon or main window).
- Click the `25:00` item to open the popover.
- macOS will ask for notification permission when the first session completes.

## Using the timer

1. Click the menu bar item to open the popover.
2. In the **Timer** tab, click **Start** to begin a focus session.
3. Use **Pause**, **Reset**, or **Skip** as needed.
4. When a session ends:
   - If auto-start is on, the next session begins automatically.
   - If auto-start is off, the timer stops at 00:00 and waits for you.

Adjust durations, auto-start, and the Tasks tab in **Settings**.

## Notes

- All data (tasks, history, settings) is stored locally under `~/Library/Application Support/Altar/`.
- There is no server, sync, app/website blocking, or automation.

## License

Personal use. Add a license here if you plan to share or open source it.
