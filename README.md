# Altar – macOS Menu Bar Pomodoro App

Altar is a native macOS menu bar Pomodoro / focus timer. It lets you:

- Run a configurable Pomodoro-style focus timer from the macOS menu bar
- Track focus time against simple tasks
- See basic reports of your focus time (today / this week, plus per-task breakdown)

Everything runs locally on your Mac; there is no sync or app/website blocking.

## Features

- **Menu bar timer**
  - Lives in the macOS menu bar as a time label (e.g. `25:00`)
  - One click opens a compact popover UI
  - Quick Quit button in the popover

- **Pomodoro timer**
  - Focus, short break, and long break sessions
  - Configurable durations and long-break frequency
  - Optional auto-start of the next session
  - Skip and reset actions
  - Simple local notification when a session or break completes

- **Tasks**
  - Add lightweight tasks with a title
  - Mark tasks complete, delete when done
  - See how many Pomodoro sessions have been completed per task
  - Associate the current focus session with a task

- **Reports**
  - View total focus time and completed focus sessions:
    - Today
    - This week
  - See a simple per-task breakdown of focus time for the selected range

## Project structure

- `Altar.xcodeproj` – Xcode project for the macOS app (open in Xcode)
- `Altar/` – App source:
  - `AltarApp.swift` – SwiftUI `@main` entry and `NSApplicationDelegate`
  - `Info.plist` – app bundle configuration (includes `LSUIElement` so the app only appears in the menu bar)
  - `Assets.xcassets` – app icon and asset catalog
  - `Models/`
    - `TimerSettings.swift` – timer configuration and `SessionType`
    - `Task.swift` – task model
    - `SessionHistory.swift` – session record model for reports
  - `Services/`
    - `PersistenceService.swift` – JSON-based storage for tasks and session history
    - `NotificationService.swift` – local notifications for completed sessions
    - `SettingsManager.swift` – UserDefaults-backed timer settings
  - `ViewModels/`
    - `TaskStore.swift` – observable task list with persistence
    - `HistoryStore.swift` – observable session history with persistence and helpers for reports
    - `TimerViewModel.swift` – Pomodoro timer state machine and session logic
  - `Views/`
    - `MenuBarContentView.swift` – root popover with segmented navigation
    - `TimerView.swift` – timer UI and controls
    - `TaskListView.swift` – task management list
    - `ReportsView.swift` – basic reports and per-task breakdown
    - `SettingsView.swift` – timer configuration UI
  - `StatusItemController.swift` – AppKit status item and SwiftUI popover host

## Requirements

- macOS 11.0 or later
- Xcode (latest stable, tested with Xcode 15+)

## Running the app

1. Open `Altar.xcodeproj` in Xcode.
2. Select the `Altar` scheme and your Mac as the run destination.
3. Build & run.

On first launch:

- The app will appear **only in the menu bar** (no Dock icon or main window).
- A new menu bar item (initially `25:00`) will appear; click it to open the popover.
- macOS will ask for permission to send notifications when the first session completes.

## Using the timer

1. Click the menu bar item to open the Altar popover.
2. In the **Timer** tab:
   - Click **Start** to begin a focus session.
   - Click **Pause** to pause, **Reset** to reset the current session, or **Skip** to record an incomplete session and move on.
3. Optionally pick a task to associate with the current focus session.
4. When a session completes, you’ll get a local notification and the timer will:
   - Move to a short or long break, or
   - Return to a focus session, depending on your settings.

You can adjust durations and auto-start behavior in the **Settings** tab.

## Notes

- All data (tasks, history, settings) is stored locally under your user’s Application Support directory.
- There is no server component, sync, app/website blocking, or Shortcuts-style automation in this version.

## License

This project is currently for personal use and experimentation. Add a license here if you plan to share or open source it.

