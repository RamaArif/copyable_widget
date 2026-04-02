# copyable_widget

[![pub package](https://img.shields.io/pub/v/copyable_widget.svg)](https://pub.dev/packages/copyable_widget)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-lightgrey)](https://pub.dev/packages/copyable_widget)

Zero-boilerplate clipboard copy for any Flutter widget or text — long-press or tap, with haptic feedback and SnackBar confirmation out of the box.

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
  copyable_widget: ^1.0.0
```

```dart
import 'package:copyable_widget/copyable_widget.dart';
```

---

## Quick start

```dart
// Drop-in text replacement — long-press to copy on mobile, tap on desktop/web
Copyable.text("TXN-9182736")

// Wrap any widget — value and child are deliberately decoupled
Copyable(
  value: accountNumber,
  child: AccountNumberRow(...),
)
```

---

## API reference

### `Copyable` widget

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `String` | required | String written to the clipboard |
| `child` | `Widget` | required | Widget displayed to the user |
| `mode` | `CopyableActionMode?` | auto | `tap` or `longPress` (null = auto-detect) |
| `feedback` | `CopyableFeedback` | `snackBar()` | What happens after copy |
| `haptic` | `HapticFeedbackStyle` | `lightImpact` | Haptic style fired after copy |

### `Copyable.text` factory

Identical to `Copyable` but wraps a `Text` widget. Accepts all standard `Text` parameters (`style`, `textAlign`, `overflow`, `maxLines`, etc.).

### `CopyableFeedback` options

| Constructor | Behaviour |
|---|---|
| `CopyableFeedback.snackBar({text, duration})` | Shows a SnackBar styled by your `ThemeData.snackBarTheme` |
| `CopyableFeedback.custom(fn)` | Calls `fn(BuildContext, CopyableEvent)` — you own 100% of the UI |
| `CopyableFeedback.none()` | Silent — clipboard write and haptic only |

### `CopyableActionMode`

| Value | Default on |
|---|---|
| `longPress` | Android, iOS |
| `tap` | Web, macOS, Windows, Linux |

### `CopyableEvent` (passed to `custom` callback)

| Field | Type | Description |
|---|---|---|
| `value` | `String` | The string copied to the clipboard |
| `timestamp` | `DateTime` | When the copy occurred |
| `mode` | `CopyableActionMode` | Whether triggered by tap or longPress |

---

## Usage examples

```dart
// 1. Minimal — all defaults
Copyable.text("TXN-9182736")

// 2. Explicit tap mode for a dedicated copy row
Copyable(
  value: accountNumber,
  mode: CopyableActionMode.tap,
  child: CopyButtonRow(...),
)

// 3. Custom SnackBar message
Copyable.text(
  "TXN-9182736",
  feedback: CopyableFeedback.snackBar(text: "Transaction ID copied"),
)

// 4. Fully custom feedback using event context
Copyable(
  value: walletAddress,
  feedback: CopyableFeedback.custom(
    (context, event) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: ${event.value.substring(0, 6)}…')),
    ),
  ),
  child: WalletAddressTile(...),
)

// 5. Silent copy — manage your own state
Copyable(
  value: apiKey,
  feedback: CopyableFeedback.none(),
  child: ApiKeyCard(...),
)

// 6. Different haptic style
Copyable.text(
  promoCode,
  haptic: HapticFeedbackStyle.mediumImpact,
  feedback: CopyableFeedback.snackBar(text: 'Promo code copied'),
)
```

---

## Platform support

| Feature | Android | iOS | Web | macOS | Windows | Linux |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Clipboard write | ✅ | ✅ | ✅ ¹ | ✅ | ✅ | ✅ |
| Haptic feedback | ✅ | ✅ | no-op | no-op | no-op | no-op |
| SnackBar feedback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Default mode | `longPress` | `longPress` | `tap` | `tap` | `tap` | `tap` |

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
