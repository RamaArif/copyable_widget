// BuildContext is required by CopyableFeedback.custom's callback signature.
// This is the only Flutter import in the domain layer and is intentional —
// feedback strategies are UI-facing by nature.
import 'package:flutter/widgets.dart' show BuildContext;

import 'copyable_event.dart';

/// Defines what happens visually after a successful clipboard copy.
///
/// Three mutually exclusive strategies:
///
/// * [CopyableFeedback.snackBar] — built-in SnackBar (default, zero deps)
/// * [CopyableFeedback.custom] — developer supplies the full feedback UI
/// * [CopyableFeedback.none] — silent copy, no UI feedback at all
sealed class CopyableFeedback {
  const CopyableFeedback();

  /// Shows a [SnackBar] via [ScaffoldMessenger].
  ///
  /// Styled entirely by the app's own [ThemeData.snackBarTheme] — the package
  /// applies no custom style. Requires a [Scaffold] ancestor in the tree.
  ///
  /// When [text] or [duration] are null, their values are resolved from
  /// the nearest [CopyableTheme] (or its defaults) in the widget tree.
  const factory CopyableFeedback.snackBar({
    String? text,
    Duration? duration,
  }) = SnackBarFeedback;

  /// Calls [onCopied] with the [BuildContext] and the full [CopyableEvent].
  ///
  /// The developer owns 100% of the feedback UI. Use this for toasts,
  /// overlays, animations, or any feedback beyond a plain SnackBar.
  factory CopyableFeedback.custom(
    void Function(BuildContext context, CopyableEvent event) onCopied,
  ) = CustomFeedback;

  /// Silent copy — clipboard write and haptic only, no visual feedback.
  const factory CopyableFeedback.none() = NoneFeedback;
}

/// Built-in SnackBar feedback. Created via [CopyableFeedback.snackBar].
final class SnackBarFeedback extends CopyableFeedback {
  const SnackBarFeedback({
    this.text,
    this.duration,
  });

  /// The message shown inside the SnackBar.
  ///
  /// When null, resolves to [CopyableThemeData.snackBarText] from the nearest
  /// [CopyableTheme], which defaults to `'Copied!'`.
  final String? text;

  /// How long the SnackBar is displayed.
  ///
  /// When null, resolves to [CopyableThemeData.snackBarDuration] from the
  /// nearest [CopyableTheme], which defaults to 2 seconds.
  final Duration? duration;
}

/// Custom feedback callback. Created via [CopyableFeedback.custom].
final class CustomFeedback extends CopyableFeedback {
  const CustomFeedback(this.onCopied);

  /// Called after the clipboard write and haptic, with full event context.
  final void Function(BuildContext context, CopyableEvent event) onCopied;
}

/// No-op feedback. Created via [CopyableFeedback.none].
final class NoneFeedback extends CopyableFeedback {
  const NoneFeedback();
}
