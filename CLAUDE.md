# CLAUDE.md — copyable_widget

Persistent context for AI-assisted development on this pub.dev Flutter package.

---

## Project Overview

**Package**: `copyable_widget` (pub.dev)
**Repo**: github.com/RamaArif/copyable_widget
**Purpose**: Zero-boilerplate clipboard copy for any Flutter widget or text, with haptic feedback and SnackBar confirmation.
**Public API surface**: `Copyable`, `CopyableText`, `CopyableBuilder`, `CopyableTheme`, `CopyableThemeData`, `CopyableActionMode`, `CopyableEvent`, `CopyableFeedback`, `HapticFeedbackStyle`

---

## Architecture

Four-layer Flutter Clean Architecture. Every new file belongs in exactly one layer.

```
lib/src/
├── domain/          # Pure Dart — ZERO Flutter deps allowed here
│   ├── models/      # Immutable value objects, enums, sealed classes
│   │   ├── copyable_action_mode.dart
│   │   ├── copyable_event.dart
│   │   ├── copyable_feedback.dart
│   │   ├── copyable_theme_data.dart
│   │   └── haptic_feedback_style.dart
│   └── services/    # Abstract interfaces (ports)
├── data/            # Flutter implementations of domain interfaces
├── application/     # Use-case orchestration (CopyHandler)
└── presentation/    # Widgets — no business logic
    ├── copyable.dart
    ├── copyable_builder.dart
    ├── copyable_text.dart
    └── copyable_theme.dart
```

**Hard rule**: `domain/` must never import `package:flutter/`. It may only import `dart:` and other `domain/` files. This is the single most important architectural constraint.

**Dependency direction**:
```
presentation → application → domain ← data
```
`data/` points inward (implements domain interfaces), never the reverse.

---

## Layer Responsibilities

| Layer | Allowed imports | Examples |
|---|---|---|
| `domain/models` | `dart:` only | `CopyableEvent`, enums |
| `domain/services` | `dart:`, other domain | Abstract `ClipboardService` |
| `data/` | `package:flutter/`, `domain/` | `ClipboardServiceImpl` |
| `application/` | `domain/`, `data/` | `CopyHandler` |
| `presentation/` | `package:flutter/`, `application/`, `domain/models` | `Copyable`, `CopyableText` |

---

## Public API Rules

- **One file = one public class, enum, or widget. No exceptions.**
- **Barrel file**: `lib/copyable_widget.dart` is the single public entry point.
- Export only models and widgets. Never export `data/`, `application/`, or `domain/services/`.
- `lib/src/` is private — consumers must not import from it directly (Dart analyzer enforces this).
- Use selective exports (named files, not `export *`).
- All public classes, methods, and parameters need `///` dartdoc comments with a usage example.

---

## Code Style

- Dart 3 features preferred: sealed classes, exhaustive switch, records, patterns.
- `final class` for implementations that must not be extended (`ClipboardServiceImpl`, `HapticServiceImpl`).
- `const` constructors on all value objects and widgets where possible.
- `StatefulWidget` is permitted in `presentation/` when state is purely UI-local (e.g. timer management for `clearAfter`, `isCopied` toggle in `CopyableBuilder`).
- `context.mounted` guard before any post-`await` widget interaction.
- Linting: `flutter_lints` + `prefer_const_constructors`, `prefer_final_fields`, `use_super_parameters`.

---

## Testing

Tests are separated by type, not by source layer:

```
test/
├── unit/
│   └── application/   → copy_handler_test.dart
└── widget/
    └── presentation/  → copyable_test.dart
```

- `unit/`: Pure Dart tests — inject mock services, no platform channels needed.
- `widget/`: Flutter widget tests — use `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, ...)` to silence `MissingPluginException`.
- To intercept `Clipboard.setData` in widget tests, capture `call.arguments['text']` inside the mock handler — do not use `ClipboardServiceImpl` directly.
- No integration tests (package scope is too small to justify them).

Run tests:
```bash
flutter test
```

---

## Versioning & Changelog

Follows **Semantic Versioning**:
- **MAJOR**: Breaking public API change (rename, remove, signature change).
- **MINOR**: Backward-compatible new feature or parameter.
- **PATCH**: Bug fix with no API change.
- **+build**: Non-API change (docs, CI, refactor).

Update `CHANGELOG.md` and `pubspec.yaml` version together. Format:
```markdown
## X.Y.Z
- What changed, written for package consumers (not implementation details).
```

---

## Common Commands

```bash
# Run all tests
flutter test

# Analyze for lint errors
flutter analyze

# Dry-run publish check
flutter pub publish --dry-run

# Format all Dart files
dart format lib/ test/
```

---

## What Not To Do

- Do not add Flutter imports to `domain/`.
- Do not export anything from `lib/src/data/`, `lib/src/application/`, or `lib/src/domain/services/`.
- Do not introduce external dependencies — the package intentionally has zero non-SDK deps.
- Do not add unnecessary stateful widgets to `presentation/` — only use `StatefulWidget` when local state is required (timers, `isCopied`).
- Do not mock `ClipboardServiceImpl` in widget tests — mock the platform channel instead (mirrors real-world behavior).
- Do not add `infrastructure/` as a folder name — the convention in this repo is `data/`.
- Do not skip `CHANGELOG.md` updates on any version bump.
