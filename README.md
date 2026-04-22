# copyable_widget

[![pub package](https://img.shields.io/pub/v/copyable_widget.svg)](https://pub.dev/packages/copyable_widget)
[![CI](https://github.com/RamaArif/copyable_widget/actions/workflows/ci.yml/badge.svg)](https://github.com/RamaArif/copyable_widget/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/RamaArif/copyable_widget/branch/main/graph/badge.svg)](https://codecov.io/gh/RamaArif/copyable_widget)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-lightgrey)](https://pub.dev/packages/copyable_widget)

Zero-boilerplate clipboard copy for any Flutter widget or text — tap, with haptic feedback and SnackBar confirmation out of the box.

**[Live Demo →](https://RamaArif.github.io/copyable_widget/)**

---

## The problem

Every Flutter screen with copyable data forces you to write the same boilerplate over and over:

```dart
GestureDetector(
  onLongPress: () {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied!')),
    );
  },
  child: widget,
)
```

`copyable_widget` eliminates all of it.

---

## Installation

```yaml
dependencies:
  copyable_widget: ^1.3.0
```

```dart
import 'package:copyable_widget/copyable_widget.dart';
```

---

## Quick start

```dart
// Drop-in text shorthand — tap to copy, shows "Copied!" SnackBar
Copyable.text("TXN-9182736")

// 1-line copy button shorthand
Copyable.icon("TXN-9182736")

// Show a label but copy a different value
Copyable.text(
  "Copy card number",
  value: cardNumber,
)

// Wrap any widget — value and child are deliberately decoupled
Copyable(
  value: accountNumber,
  child: AccountNumberRow(...),
)

// Wrap only the copy icon, leaving the rest of the row non-interactive
Row(
  children: [
    Text(accountNumber),
    Copyable(
      value: accountNumber,
      child: Icon(Icons.copy_rounded),
    ),
  ],
)
```

---

## API reference

### `Copyable` widget

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `String` | required | String written to the clipboard |
| `child` | `Widget` | required | Widget displayed to the user |
| `mode` | `CopyableActionMode?` | `tap` | `tap` or `longPress` (null defaults to `tap` on all platforms) |
| `feedback` | `CopyableFeedback` | `snackBar()` | What happens after copy |
| `haptic` | `HapticFeedbackStyle` | `lightImpact` | Haptic style fired after copy |
| `clearAfter` | `Duration?` | `null` | Clears clipboard after this duration (falls back to `CopyableTheme`) |
| `onError` | `void Function(Object)?` | `null` | Called when `Clipboard.setData` throws |
| `onCopied` | `void Function(CopyableEvent)?` | `null` | Called after a successful copy with the copied value, timestamp, and mode |

### `Copyable.text` factory

| Parameter | Type | Default | Description |
|---|---|---|---|
| `data` | `String` | required | Text string displayed to the user |
| `value` | `String?` | `null` | String written to the clipboard. When omitted, `data` is copied instead — use this to show a label (e.g. `"Copy card number"`) while copying a different value |
| `mode` | `CopyableActionMode?` | `tap` | `tap` or `longPress` (null defaults to `tap` on all platforms) |
| `feedback` | `CopyableFeedback` | `snackBar()` | What happens after copy |
| `haptic` | `HapticFeedbackStyle` | `lightImpact` | Haptic style fired after copy |
| `clearAfter` | `Duration?` | `null` | Clears clipboard after this duration (falls back to `CopyableTheme`) |
| `onError` | `void Function(Object)?` | `null` | Called when `Clipboard.setData` throws |
| `onCopied` | `void Function(CopyableEvent)?` | `null` | Called after a successful copy with the copied value, timestamp, and mode |

Also accepts all standard `Text` parameters (`style`, `textAlign`, `overflow`, `maxLines`, etc.).

### `Copyable.icon` factory

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `String` | required | String written to the clipboard |
| `icon` | `IconData` | `Icons.copy_rounded` | Icon displayed to the user |
| `size` | `double?` | `null` | Forwarded to the underlying `Icon` |
| `color` | `Color?` | `null` | Forwarded to the underlying `Icon` |
| `mode` | `CopyableActionMode?` | `tap` | `tap`, `longPress`, or `doubleTap` |
| `feedback` | `CopyableFeedback` | `snackBar()` | What happens after copy |
| `haptic` | `HapticFeedbackStyle` | `lightImpact` | Haptic style fired after copy |
| `clearAfter` | `Duration?` | `null` | Clears clipboard after this duration (falls back to `CopyableTheme`) |
| `onError` | `void Function(Object)?` | `null` | Called when `Clipboard.setData` throws |
| `onCopied` | `void Function(CopyableEvent)?` | `null` | Called after a successful copy with the copied value, timestamp, and mode |

### `CopyableFeedback` options

| Constructor | Behaviour |
|---|---|
| `CopyableFeedback.snackBar({text, duration})` | Shows a SnackBar styled by your `ThemeData.snackBarTheme` |
| `CopyableFeedback.custom(fn)` | Calls `fn(BuildContext, CopyableEvent)` — you own 100% of the UI |
| `CopyableFeedback.none()` | Silent — clipboard write and haptic only |

### `CopyableActionMode`

| Value | Description |
|---|---|
| `tap` | Default on all platforms |
| `longPress` | Pass explicitly when long-press behaviour is needed |
| `doubleTap` | Use when single-tap and long-press are already reserved or double-tap is the preferred copy gesture |

### `CopyableEvent` (passed to `custom` callback)

| Field | Type | Description |
|---|---|---|
| `value` | `String` | The string copied to the clipboard |
| `timestamp` | `DateTime` | When the copy occurred |
| `mode` | `CopyableActionMode` | Whether triggered by tap, longPress, or doubleTap |

---

## Usage examples

```dart
// 1. Minimal — all defaults
Copyable.text("TXN-9182736")

// 2. Icon shorthand
Copyable.icon("TXN-9182736", icon: Icons.content_copy, color: Colors.blue)

// 3. Label + value — display one string, copy another
Copyable.text(
  "Copy card number",
  value: cardNumber,
  feedback: CopyableFeedback.snackBar(text: 'Card number copied!'),
)

// 3. Wrap only the copy icon — row itself stays non-interactive
Row(
  children: [
    Text(accountNumber, style: TextStyle(fontFamily: 'monospace')),
    const Spacer(),
    Copyable(
      value: accountNumber,
      feedback: CopyableFeedback.snackBar(text: 'Copied!'),
      child: Icon(Icons.copy_rounded),
    ),
  ],
)

// 4. Wrap the entire row
Copyable(
  value: accountNumber,
  child: AccountNumberRow(...),
)

// 5. Custom SnackBar message
Copyable.text(
  "TXN-9182736",
  feedback: CopyableFeedback.snackBar(text: "Transaction ID copied"),
)

// 6. Fully custom feedback using event context
Copyable(
  value: walletAddress,
  feedback: CopyableFeedback.custom(
    (context, event) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: ${event.value.substring(0, 6)}…')),
    ),
  ),
  child: WalletAddressTile(...),
)

// 8. Silent copy — manage your own state
Copyable(
  value: apiKey,
  feedback: CopyableFeedback.none(),
  child: ApiKeyCard(...),
)

// 9. Long-press mode (explicit)
Copyable.text(
  "Hold to copy",
  mode: CopyableActionMode.longPress,
)

// 10. Double-tap mode (analytics tracking)
Copyable.text(
  "Double tap",
  mode: CopyableActionMode.doubleTap,
  onCopied: (event) => analytics.track('copied', {'value': event.value}),
)
```

---

## CopyableTheme

`CopyableTheme` is an `InheritedWidget` that sets app-wide defaults for all `Copyable` and `CopyableBuilder` widgets. Per-widget values always override theme values.

```dart
CopyableTheme(
  data: CopyableThemeData(
    snackBarText: 'Copied to clipboard',
    snackBarDuration: Duration(seconds: 3),
    clearAfter: Duration(seconds: 30), // global secure clear
  ),
  child: Scaffold(
    body: Column(
      children: [
        // Uses theme snackBarText and clearAfter automatically
        Copyable.text('TXN-9182736'),
        // Per-widget overrides the theme
        Copyable.text(
          'Quick copy',
          feedback: CopyableFeedback.snackBar(text: 'Done!'),
          clearAfter: Duration(seconds: 5),
        ),
      ],
    ),
  ),
)
```

### `CopyableThemeData`

| Field | Type | Default | Description |
|---|---|---|---|
| `snackBarText` | `String` | `'Copied!'` | Default SnackBar message when no per-widget text is set |
| `snackBarDuration` | `Duration` | `Duration(seconds: 2)` | Default SnackBar duration |
| `clearAfter` | `Duration?` | `null` | Default clipboard clear delay for all widgets |

---

## clearAfter — Automatic Clipboard Security

For FinTech, crypto, and any app that handles sensitive data, `clearAfter` automatically overwrites the clipboard with an empty string after a specified duration:

```dart
// Clears clipboard 30 seconds after copy — per widget
Copyable(
  value: privateKey,
  clearAfter: Duration(seconds: 30),
  child: PrivateKeyCard(...),
)

// Or set it globally via CopyableTheme
CopyableTheme(
  data: CopyableThemeData(clearAfter: Duration(seconds: 30)),
  child: MyApp(),
)
```

---

## CopyableBuilder

`CopyableBuilder` gives you full control over the copy UI by exposing an `isCopied` boolean via a builder function. No SnackBar is shown — you own 100% of the visual feedback.

```dart
// GitHub-style icon toggle
CopyableBuilder(
  value: walletAddress,
  builder: (context, isCopied) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    child: isCopied
        ? const Icon(Icons.check, key: ValueKey('check'), color: Colors.green)
        : const Icon(Icons.copy_rounded, key: ValueKey('copy')),
  ),
)

// Animated copy button
CopyableBuilder(
  value: apiKey,
  resetAfter: Duration(seconds: 3),
  clearAfter: Duration(seconds: 60),
  onCopied: (event) => print('Copied at ${event.timestamp}'),
  builder: (context, isCopied) => ElevatedButton(
    onPressed: null, // tap handled by CopyableBuilder
    child: Text(isCopied ? 'Copied!' : 'Copy API Key'),
  ),
)
```

### `CopyableBuilder` parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `String` | required | String written to the clipboard |
| `builder` | `Widget Function(BuildContext, bool)` | required | Builder receiving `isCopied` state |
| `mode` | `CopyableActionMode?` | `tap` | `tap` or `longPress` |
| `haptic` | `HapticFeedbackStyle` | `lightImpact` | Haptic style fired after copy |
| `resetAfter` | `Duration` | `Duration(seconds: 2)` | How long `isCopied` stays `true` |
| `clearAfter` | `Duration?` | `null` | Clears clipboard after this duration |
| `onError` | `void Function(Object)?` | `null` | Called when clipboard write fails |
| `onCopied` | `void Function(CopyableEvent)?` | `null` | Called after successful copy with full event context |

---

## Platform support

| Feature | Android | iOS | Web | macOS | Windows | Linux |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Clipboard write | ✅ | ✅ | ✅ ¹ | ✅ | ✅ | ✅ |
| Haptic feedback | ✅ | ✅ | no-op | no-op | no-op | no-op |
| SnackBar feedback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Default mode | `tap` | `tap` | `tap` | `tap` | `tap` | `tap` |

> ¹ Web clipboard write is initiated from a user gesture, which is guaranteed.

No conditional platform code required — Flutter's own APIs degrade gracefully.

---

## SnackBar styling

The package applies **no custom style** to the SnackBar. All styling — color, shape, elevation, behavior — is controlled by your existing `ThemeData.snackBarTheme`:

```dart
MaterialApp(
  theme: ThemeData(
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
)
```

> `CopyableFeedback.snackBar()` requires a `Scaffold` ancestor. Use `CopyableFeedback.custom()` or `CopyableFeedback.none()` when no Scaffold is present.

---

## Dependencies

Zero external dependencies. Only Flutter SDK (`flutter/services`, `flutter/material`).

---

## Contributing

Issues and pull requests are welcome at [github.com/RamaArif/copyable_widget](https://github.com/RamaArif/copyable_widget).

## License

[MIT](LICENSE)
