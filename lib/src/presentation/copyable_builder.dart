import 'dart:async';

import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, HapticFeedback;
import 'package:flutter/widgets.dart';

import '../domain/models/copyable_action_mode.dart';
import '../domain/models/copyable_event.dart';
import '../domain/models/haptic_feedback_style.dart';
import '_clear_timer_mixin.dart';
import 'copyable_theme.dart';

/// A fully custom copy widget that exposes an `isCopied` boolean state.
///
/// Use this when you need complete control over the copy UI — e.g. a
/// GitHub-style icon toggle, an animated container, or any UI that needs to
/// react visually to the copied state.
///
/// ```dart
/// CopyableBuilder(
///   value: walletAddress,
///   builder: (context, isCopied) => AnimatedSwitcher(
///     duration: const Duration(milliseconds: 200),
///     child: isCopied
///       ? const Icon(Icons.check, key: ValueKey('check'))
///       : const Icon(Icons.copy_rounded, key: ValueKey('copy')),
///   ),
/// )
/// ```
///
/// The `isCopied` flag is automatically reset to `false` after [resetAfter]
/// (default 2 seconds). The clipboard can be automatically cleared after
/// [clearAfter] (or the nearest [CopyableTheme] value).
class CopyableBuilder extends StatefulWidget {
  const CopyableBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.mode,
    this.haptic = HapticFeedbackStyle.lightImpact,
    this.resetAfter = const Duration(seconds: 2),
    this.clearAfter,
    this.onError,
    this.onCopied,
  });

  /// The string written to the clipboard when the gesture fires.
  final String value;

  /// Builder that receives the current `isCopied` state.
  ///
  /// Called on every rebuild. Use `isCopied` to toggle icons, colors, or text.
  final Widget Function(BuildContext context, bool isCopied) builder;

  /// The gesture that triggers the copy.
  ///
  /// Defaults to [CopyableActionMode.tap] on all platforms when null.
  final CopyableActionMode? mode;

  /// The haptic style fired after the clipboard write.
  ///
  /// Defaults to [HapticFeedbackStyle.lightImpact]. Silent on platforms
  /// without haptic hardware.
  final HapticFeedbackStyle haptic;

  /// How long `isCopied` stays `true` before automatically resetting to
  /// `false`. Defaults to 2 seconds.
  final Duration resetAfter;

  /// Automatically overwrites the clipboard with an empty string after this
  /// duration. When null, falls back to [CopyableThemeData.clearAfter].
  final Duration? clearAfter;

  /// Called when [Clipboard.setData] throws an error.
  ///
  /// When provided, no haptic or state change is triggered on failure.
  final void Function(Object)? onError;

  /// Called after a successful copy with full event context.
  ///
  /// Receives a [CopyableEvent] containing the value, timestamp, and mode.
  final void Function(CopyableEvent)? onCopied;

  @override
  State<CopyableBuilder> createState() => _CopyableBuilderState();
}

class _CopyableBuilderState extends State<CopyableBuilder>
    with ClearAfterMixin<CopyableBuilder> {
  bool _isCopied = false;
  bool _isCopying = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose(); // ClearAfterMixin.dispose cancels the clear timer
  }

  Future<void> _handleCopy() async {
    if (_isCopying) return;
    _isCopying = true;
    try {
      await Clipboard.setData(ClipboardData(text: widget.value));
    } catch (e) {
      widget.onError?.call(e);
      _isCopying = false;
      return;
    }

    // Fire haptic feedback.
    switch (widget.haptic) {
      case HapticFeedbackStyle.lightImpact:
        await HapticFeedback.lightImpact();
      case HapticFeedbackStyle.mediumImpact:
        await HapticFeedback.mediumImpact();
      case HapticFeedbackStyle.heavyImpact:
        await HapticFeedback.heavyImpact();
      case HapticFeedbackStyle.selectionClick:
        await HapticFeedback.selectionClick();
    }

    _isCopying = false;

    if (!mounted) return;

    final theme = CopyableTheme.of(context);
    final resolvedClearAfter = widget.clearAfter ?? theme.clearAfter;
    final resolvedMode = widget.mode ?? CopyableActionMode.tap;

    setState(() => _isCopied = true);

    widget.onCopied?.call(CopyableEvent(
      value: widget.value,
      timestamp: DateTime.now(),
      mode: resolvedMode,
    ));

    _resetTimer?.cancel();
    _resetTimer = Timer(widget.resetAfter, () {
      if (mounted) setState(() => _isCopied = false);
    });

    startClearAfterTimer(resolvedClearAfter);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedMode = widget.mode ?? CopyableActionMode.tap;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: resolvedMode == CopyableActionMode.tap ? _handleCopy : null,
      onLongPress:
          resolvedMode == CopyableActionMode.longPress ? _handleCopy : null,
      onDoubleTap:
          resolvedMode == CopyableActionMode.doubleTap ? _handleCopy : null,
      child: widget.builder(context, _isCopied),
    );
  }
}
