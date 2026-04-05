/// App-wide default configuration for all [Copyable] and [CopyableBuilder]
/// widgets.
///
/// Provided through [CopyableTheme] and read by widgets during their build.
/// Per-widget values always override theme values.
///
/// ```dart
/// CopyableTheme(
///   data: CopyableThemeData(
///     snackBarText: 'Copied to clipboard',
///     snackBarDuration: Duration(seconds: 3),
///     clearAfter: Duration(seconds: 30),
///   ),
///   child: MyApp(),
/// )
/// ```
class CopyableThemeData {
  const CopyableThemeData({
    this.snackBarText = 'Copied!',
    this.snackBarDuration = const Duration(seconds: 2),
    this.clearAfter,
  });

  /// The message shown inside the SnackBar when no per-widget text is set.
  final String snackBarText;

  /// How long the SnackBar is displayed when no per-widget duration is set.
  final Duration snackBarDuration;

  /// Automatically overwrites the clipboard with an empty string after this
  /// duration. Applied when the per-widget [clearAfter] is not set.
  ///
  /// Useful for FinTech and crypto apps handling sensitive data.
  final Duration? clearAfter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopyableThemeData &&
          snackBarText == other.snackBarText &&
          snackBarDuration == other.snackBarDuration &&
          clearAfter == other.clearAfter;

  @override
  int get hashCode => Object.hash(snackBarText, snackBarDuration, clearAfter);

  static const _unset = Object();

  /// Returns a copy of this theme with the given fields replaced.
  ///
  /// Pass `clearAfter: null` to explicitly disable the clear-after feature
  /// (removes any inherited duration). Omitting [clearAfter] retains the
  /// existing value.
  CopyableThemeData copyWith({
    String? snackBarText,
    Duration? snackBarDuration,
    Object? clearAfter = _unset,
  }) {
    return CopyableThemeData(
      snackBarText: snackBarText ?? this.snackBarText,
      snackBarDuration: snackBarDuration ?? this.snackBarDuration,
      clearAfter: identical(clearAfter, _unset)
          ? this.clearAfter
          : clearAfter as Duration?,
    );
  }
}
