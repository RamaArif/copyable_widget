## 1.1.0

* `Copyable.text` now accepts an optional `value` parameter — display a label (e.g. `"Copy card number"`) while copying a different string to the clipboard
* Default gesture mode is now `tap` on **all** platforms (was `longPress` on Android/iOS); pass `mode: CopyableActionMode.longPress` explicitly when long-press is needed
* Fixed `ScaffoldMessenger.of` crash when no `Scaffold` ancestor is present (now uses `maybeOf`)
* Expanded widget-test suite with platform-channel mocking, clipboard-value interception, and label/value decoupling coverage

## 1.0.1

* Renamed package from `copyable` to `copyable_widget`
* Fixed `Copyable.text` factory return type error
* Centered SnackBar text

## 1.0.0

* **Null safety**: this version opts into sound null safety (previous versions did not)
* Initial release
* `Copyable` widget — wraps any widget with clipboard copy behavior
* `Copyable.text` — drop-in Text replacement with copy on tap/long-press
* `CopyableFeedback.snackBar()` — built-in SnackBar confirmation (default)
* `CopyableFeedback.custom()` — fully custom feedback via callback
* `CopyableFeedback.none()` — silent copy with no UI feedback
* `CopyableActionMode.tap` / `.longPress` with auto-detection per platform
* `CopyableEvent` passed to custom feedback handler with value, timestamp, and mode
* `HapticFeedbackStyle` enum for configurable haptic response
* Full platform support: Android, iOS, Web, macOS, Windows, Linux
* Zero external dependencies — Flutter SDK only
