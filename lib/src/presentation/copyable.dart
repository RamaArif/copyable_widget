import 'package:flutter/material.dart';

import '../application/copy_handler.dart';
import '../domain/models/copyable_action_mode.dart';
import '../domain/models/copyable_event.dart';
import '../domain/models/copyable_feedback.dart';
import '../domain/models/haptic_feedback_style.dart';
import '_clear_timer_mixin.dart';
import 'copyable_theme.dart';

/// Wraps any widget with clipboard copy behaviour on tap or long-press.
///
/// The displayed [child] and the copied [value] are deliberately decoupled —
/// wrap complex widgets (rows, cards, tiles) without altering their appearance.
///
/// **Quick start**
/// ```dart
/// // Wrap any widget
/// Copyable(
///   value: accountNumber,
///   child: AccountNumberRow(...),
/// )
///
/// // Drop-in Text shorthand
/// Copyable.text("TXN-9182736")
/// ```
///
/// **Feedback options**
/// ```dart
/// // Custom SnackBar message
/// Copyable.text(
///   promoCode,
///   feedback: CopyableFeedback.snackBar(text: 'Promo code copied'),
/// )
///
/// // Custom feedback UI
/// Copyable(
///   value: walletAddress,
///   feedback: CopyableFeedback.custom(
///     (context, event) => showToast('Copied ${event.value.substring(0, 6)}…'),
///   ),
///   child: WalletTile(...),
/// )
///
/// // Silent copy
/// Copyable(
///   value: apiKey,
///   feedback: CopyableFeedback.none(),
///   child: ApiKeyCard(...),
/// )
/// ```
///
/// **Mode selection**
///
/// When [mode] is null (default), [CopyableActionMode.tap] is used on all
/// platforms. Pass [CopyableActionMode.longPress] explicitly if you need
/// long-press behaviour.
///
/// **Clear after copy**
///
/// Use [clearAfter] to automatically overwrite the clipboard with an empty
/// string after the specified duration. Ideal for sensitive data:
/// ```dart
/// Copyable(
///   value: privateKey,
///   clearAfter: Duration(seconds: 30),
///   child: PrivateKeyCard(...),
/// )
/// ```
///
/// **Error handling**
///
/// Use [onError] to capture clipboard write failures:
/// ```dart
/// Copyable(
///   value: accountNumber,
///   onError: (e) => logger.error('Clipboard failed', e),
///   child: AccountRow(...),
/// )
/// ```
class Copyable extends StatefulWidget {
  /// Creates a [Copyable] that wraps [child] and copies [value] to the
  /// clipboard on the resolved gesture.
  const Copyable({
    super.key,
    required this.value,
    required this.child,
    this.mode,
    this.feedback = const SnackBarFeedback(),
    this.haptic = HapticFeedbackStyle.lightImpact,
    this.clearAfter,
    this.onError,
    this.onCopied,
  });

  /// The string written to the clipboard when the gesture fires.
  final String value;

  /// The widget displayed to the user.
  final Widget child;

  /// The gesture that triggers the copy.
  ///
  /// Defaults to [CopyableActionMode.tap] on all platforms when null.
  final CopyableActionMode? mode;

  /// What happens after a successful copy.
  ///
  /// Defaults to [CopyableFeedback.snackBar] with the message "Copied!".
  final CopyableFeedback feedback;

  /// The haptic style fired after the clipboard write.
  ///
  /// Defaults to [HapticFeedbackStyle.lightImpact]. Silent on platforms
  /// without haptic hardware.
  final HapticFeedbackStyle haptic;

  /// Automatically overwrites the clipboard with an empty string after this
  /// duration. When null, falls back to [CopyableThemeData.clearAfter].
  ///
  /// Designed for FinTech and crypto apps that handle sensitive data.
  final Duration? clearAfter;

  /// Called when [Clipboard.setData] throws an error.
  ///
  /// When provided, no haptic or feedback is triggered on failure.
  /// Use this for error logging and recovery.
  final void Function(Object)? onError;

  /// Called after a successful copy with full event context.
  ///
  /// Receives a [CopyableEvent] containing the value, timestamp, and mode.
  /// This is called regardless of the UI feedback strategy used.
  final void Function(CopyableEvent)? onCopied;

  static final _handler = CopyHandler();

  /// Shorthand for the common case of copying a text string.
  ///
  /// Equivalent to wrapping a [Text] widget with [Copyable]. All standard
  /// [Text] parameters are forwarded verbatim.
  ///
  /// The optional [value] parameter lets you decouple the displayed label from
  /// what is written to the clipboard. When omitted, [data] is copied instead.
  ///
  /// ```dart
  /// Copyable.text(
  ///   "TXN-9182736",
  ///   style: TextStyle(fontFamily: 'monospace'),
  ///   feedback: CopyableFeedback.snackBar(text: 'Transaction ID copied'),
  /// )
  ///
  /// // Show a label but copy the actual card number
  /// Copyable.text(
  ///   "Copy card number",
  ///   value: cardNumber,
  ///   feedback: CopyableFeedback.snackBar(text: 'Card number copied'),
  /// )
  /// ```
  factory Copyable.text(
    String data, {
    Key? key,
    String? value,
    CopyableActionMode? mode,
    CopyableFeedback feedback = const SnackBarFeedback(),
    HapticFeedbackStyle haptic = HapticFeedbackStyle.lightImpact,
    Duration? clearAfter,
    void Function(Object)? onError,
    void Function(CopyableEvent)? onCopied,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) =>
      Copyable(
        key: key,
        value: value ?? data,
        mode: mode,
        feedback: feedback,
        haptic: haptic,
        clearAfter: clearAfter,
        onError: onError,
        onCopied: onCopied,
        child: Text(
          data,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        ),
      );

  /// Shorthand for copying from an icon.
  ///
  /// Shows an [Icon] widget that writes [value] to the clipboard when
  /// interacted with. [icon] defaults to `Icons.copy_rounded`.
  factory Copyable.icon(
    String value, {
    Key? key,
    IconData icon = Icons.copy_rounded,
    double? size,
    Color? color,
    CopyableActionMode? mode,
    CopyableFeedback feedback = const SnackBarFeedback(),
    HapticFeedbackStyle haptic = HapticFeedbackStyle.lightImpact,
    Duration? clearAfter,
    void Function(Object)? onError,
    void Function(CopyableEvent)? onCopied,
  }) =>
      Copyable(
        key: key,
        value: value,
        mode: mode,
        feedback: feedback,
        haptic: haptic,
        clearAfter: clearAfter,
        onError: onError,
        onCopied: onCopied,
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      );

  @override
  State<Copyable> createState() => _CopyableState();
}

class _CopyableState extends State<Copyable>
    with ClearAfterMixin<Copyable> {
  bool _isCopying = false;

  Future<void> _handleCopy(BuildContext context) async {
    if (_isCopying) return;
    _isCopying = true;
    try {
      final theme = CopyableTheme.of(context);
      final resolvedMode = Copyable._handler.resolveMode(widget.mode);
      final resolvedFeedback =
          Copyable._handler.resolveFeedback(widget.feedback, theme);

      // Track whether the copy succeeded so the clear timer is not started
      // when handle() returns early due to a clipboard error.
      var copySucceeded = true;
      await Copyable._handler.handle(
        context: context,
        value: widget.value,
        resolvedMode: resolvedMode,
        feedback: resolvedFeedback,
        haptic: widget.haptic,
        onError: (e) {
          copySucceeded = false;
          widget.onError?.call(e);
        },
        onCopied: widget.onCopied,
      );

      if (!copySucceeded) return;
      startClearAfterTimer(widget.clearAfter ?? theme.clearAfter);
    } finally {
      _isCopying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedMode = Copyable._handler.resolveMode(widget.mode);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: resolvedMode == CopyableActionMode.tap
          ? () => _handleCopy(context)
          : null,
      onLongPress: resolvedMode == CopyableActionMode.longPress
          ? () => _handleCopy(context)
          : null,
      onDoubleTap: resolvedMode == CopyableActionMode.doubleTap
          ? () => _handleCopy(context)
          : null,
      child: widget.child,
    );
  }
}
