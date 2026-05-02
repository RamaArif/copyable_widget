import 'dart:async';

import 'package:flutter/material.dart';

import '../application/copy_handler.dart';
import '../domain/models/copyable_action_mode.dart';
import '../domain/models/copyable_event.dart';
import '../domain/models/copyable_feedback.dart';
import '../domain/models/haptic_feedback_style.dart';
import '_clear_timer_mixin.dart';
import '_copyable_semantics.dart';
import 'copyable_theme.dart';

/// A [Text] widget that copies its content to the clipboard on tap or
/// long-press.
///
/// Prefer constructing this via [Copyable.text] for a unified entry point.
/// All standard [Text] widget parameters are forwarded verbatim.
///
/// The optional [value] parameter lets you decouple the displayed label from
/// what is written to the clipboard. When omitted, [data] is copied instead.
///
/// Set [trailingHint] to `true` to render a small copy icon after the text,
/// making the copy affordance explicit. The icon switches to a check mark
/// briefly after a successful copy.
///
/// ```dart
/// CopyableText(
///   "TXN-9182736",
///   trailingHint: true,
///   style: TextStyle(fontFamily: 'monospace'),
/// )
/// ```
class CopyableText extends StatefulWidget {
  const CopyableText(
    this.data, {
    super.key,
    this.value,
    this.mode,
    this.feedback = const SnackBarFeedback(),
    this.haptic = HapticFeedbackStyle.lightImpact,
    this.clearAfter,
    this.onError,
    this.onCopied,
    this.semanticLabel,
    this.excludeSemantics = false,
    this.trailingHint = false,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// The text string displayed to the user.
  final String data;

  /// The string written to the clipboard when the gesture fires.
  ///
  /// When null, [data] is copied instead. Use this to show a label
  /// (e.g. "Copy card number") while copying a different value.
  final String? value;

  /// The gesture that triggers the copy. Defaults to [CopyableActionMode.tap].
  final CopyableActionMode? mode;

  /// What happens after a successful copy.
  final CopyableFeedback feedback;

  /// The haptic style fired after the clipboard write.
  final HapticFeedbackStyle haptic;

  /// Automatically overwrites the clipboard with an empty string after this
  /// duration. When null, falls back to [CopyableThemeData.clearAfter].
  final Duration? clearAfter;

  /// Called when [Clipboard.setData] throws an error.
  final void Function(Object)? onError;

  /// Called after a successful copy with full event context.
  final void Function(CopyableEvent)? onCopied;

  /// The label read by screen readers for this copyable element.
  ///
  /// When null, auto-generates from the copy value.
  final String? semanticLabel;

  /// Whether to exclude the child's semantics from the tree.
  final bool excludeSemantics;

  /// When `true`, renders a small copy icon after the text that switches to
  /// a check mark briefly after a successful copy.
  final bool trailingHint;

  // ── Text widget parameters ────────────────────────────────────────────────

  /// Forwarded to the underlying [Text] widget's [Text.style].
  final TextStyle? style;

  /// Forwarded to the underlying [Text] widget's [Text.strutStyle].
  final StrutStyle? strutStyle;

  /// Forwarded to the underlying [Text] widget's [Text.textAlign].
  final TextAlign? textAlign;

  /// Forwarded to the underlying [Text] widget's [Text.textDirection].
  final TextDirection? textDirection;

  /// Forwarded to the underlying [Text] widget's [Text.locale].
  final Locale? locale;

  /// Forwarded to the underlying [Text] widget's [Text.softWrap].
  final bool? softWrap;

  /// Forwarded to the underlying [Text] widget's [Text.overflow].
  final TextOverflow? overflow;

  /// Forwarded to the underlying [Text] widget's [Text.textScaler].
  final TextScaler? textScaler;

  /// Forwarded to the underlying [Text] widget's [Text.maxLines].
  final int? maxLines;

  /// Forwarded to the underlying [Text] widget's [Text.semanticsLabel].
  final String? semanticsLabel;

  /// Forwarded to the underlying [Text] widget's [Text.textWidthBasis].
  final TextWidthBasis? textWidthBasis;

  /// Forwarded to the underlying [Text] widget's [Text.textHeightBehavior].
  final TextHeightBehavior? textHeightBehavior;

  /// Forwarded to the underlying [Text] widget's [Text.selectionColor].
  final Color? selectionColor;

  static final _handler = CopyHandler();

  @override
  State<CopyableText> createState() => _CopyableTextState();
}

class _CopyableTextState extends State<CopyableText>
    with ClearAfterMixin<CopyableText> {
  bool _isCopying = false;
  bool _isCopied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy(BuildContext context) async {
    if (_isCopying) return;
    _isCopying = true;
    try {
      final theme = CopyableTheme.of(context);
      final resolvedMode = CopyableText._handler.resolveMode(widget.mode);
      final resolvedFeedback =
          CopyableText._handler.resolveFeedback(widget.feedback, theme);

      var copySucceeded = true;
      await CopyableText._handler.handle(
        context: context,
        value: widget.value ?? widget.data,
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

      if (context.mounted) {
        announceCopied(context);
      }

      if (widget.trailingHint && mounted) {
        setState(() => _isCopied = true);
        _resetTimer?.cancel();
        _resetTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isCopied = false);
        });
      }

      startClearAfterTimer(widget.clearAfter ?? theme.clearAfter);
    } finally {
      _isCopying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedMode = CopyableText._handler.resolveMode(widget.mode);
    final copyValue = widget.value ?? widget.data;
    final label = widget.semanticLabel ?? copyableAutoLabel(copyValue);

    final textWidget = Text(
      widget.data,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );

    final Widget content;
    if (widget.trailingHint) {
      final iconColor =
          widget.style?.color ?? DefaultTextStyle.of(context).style.color;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: textWidget),
          const SizedBox(width: 4),
          Icon(
            _isCopied ? Icons.check : Icons.copy_rounded,
            size: 16,
            color: iconColor?.withValues(alpha: 0.6),
          ),
        ],
      );
    } else {
      content = textWidget;
    }

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: widget.excludeSemantics,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
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
          child: content,
        ),
      ),
    );
  }
}

