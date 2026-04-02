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
