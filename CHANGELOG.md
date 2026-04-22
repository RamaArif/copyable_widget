## 1.3.0

* **New:** Added `onCopied` callback to `Copyable`, `Copyable.text`, and `CopyableBuilder` for tracking copies without needing custom feedback UI
* **New:** Added `Copyable.icon` convenience factory for quick 1-line copy buttons
* **New:** Added `CopyableActionMode.doubleTap` support across `Copyable`, `Copyable.text`, and `CopyableBuilder` for scenarios where single/long-press gestures are already handled by the child widget
* **CI:** Added GitHub Actions workflow for automated analysis + test + coverage on every PR
* **Docs:** Completed 100% dartdoc coverage — all public symbols documented
* **Docs:** Fixed 3 unresolved `[isCopied]` dartdoc reference warnings
* **Meta:** Added `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`

## 1.2.0

* **New:** `CopyableBuilder` widget — exposes `isCopied` boolean state via builder function for fully custom copy UI (GitHub-style icon toggle, animated containers, etc.)
* **New:** `clearAfter` parameter on `Copyable` and `Copyable.text` — automatically overwrites clipboard after a specified duration. Designed for FinTech and crypto apps handling sensitive data.
* **New:** `CopyableTheme` — `InheritedWidget` for app-wide defaults. Controls `snackBarText`, `snackBarDuration`, and `clearAfter`. Per-widget values always override theme.
* **New:** `CopyableThemeData` — data class backing `CopyableTheme`.
* **New:** `onError` callback on `Copyable`, `Copyable.text`, and `CopyableBuilder` — called when `Clipboard.setData` throws, enabling error logging and recovery.
* **Fix:** `CopyableFeedback.snackBar(text:)` now accepts nullable text — resolves to `CopyableTheme.snackBarText` when not provided.

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
