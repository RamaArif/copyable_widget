import 'package:flutter/widgets.dart';

import '../application/copy_handler.dart';
import '../domain/models/copyable_action_mode.dart';
import '../domain/models/copyable_feedback.dart';
import '../domain/models/haptic_feedback_style.dart';

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
class Copyable extends StatelessWidget {
  /// Creates a [Copyable] that wraps [child] and copies [value] to the
  /// clipboard on the resolved gesture.
  const Copyable({
    super.key,
    required this.value,
    required this.child,
    this.mode,
    this.feedback = const SnackBarFeedback(),
    this.haptic = HapticFeedbackStyle.lightImpact,
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

  @override
  Widget build(BuildContext context) {
    final resolvedMode = _handler.resolveMode(mode);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: resolvedMode == CopyableActionMode.tap
          ? () => _handler.handle(
                context: context,
                value: value,
                resolvedMode: resolvedMode,
                feedback: feedback,
                haptic: haptic,
              )
          : null,
      onLongPress: resolvedMode == CopyableActionMode.longPress
          ? () => _handler.handle(
                context: context,
                value: value,
                resolvedMode: resolvedMode,
                feedback: feedback,
                haptic: haptic,
              )
          : null,
      child: child,
    );
  }
}
