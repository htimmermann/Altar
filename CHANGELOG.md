# Changelog

All notable changes to this project are documented in this file.

## [3.1.0] - 2026-04-05

### Added

- Flush in-flight focus time to disk when the app quits so partial sessions are not lost.

### Fixed

- Partial focus time is recorded when pausing or locking the screen mid-session (not only on skip or full completion).

## [3.0.0] - 2026-03-16

### Added

- Auto-pause when the laptop is locked or the screen sleeps.
- Reports include partially completed sessions (skipped, paused, etc.).
- Typeable text fields for duration settings (replacing steppers).
- Bar chart color picker in Settings.
- Report ranges: 7 days, 30 days, All Time.
- Daily and weekly focus goals with a dotted goal line on the bar chart.

### Changed

- Removed standalone “Today” view; chart always shows multi-day context.

## [2.0.0] - 2026-03-07

### Fixed

- Timer tick ran at double speed in some cases.

### Changed

- More compact popover window.
- Tasks tab optional (off by default; enable in Settings).
- Auto-start next session off by default; timer stops at 00:00 until you continue.
- Settings redesigned with toggles in one place.

### Added

- Daily bar chart of focus minutes in Reports.
