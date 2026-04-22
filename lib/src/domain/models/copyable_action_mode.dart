/// Controls which gesture triggers the clipboard copy.
enum CopyableActionMode {
  /// Copy on single tap.
  ///
  /// Best for widgets whose only purpose is copying (e.g. a dedicated copy
  /// icon+label row, a promo code tile). There must be no other tap handler
  /// on the child, or it will be swallowed.
  tap,

  /// Copy on long-press (default on Android and iOS).
  ///
  /// Safe alongside child `onTap` handlers (e.g. a list tile that also
  /// navigates). Note: if the child has its own `onLongPress`, they will
  /// compete in the gesture arena.
  longPress,

  /// Copy on double-tap.
  ///
  /// Useful when a child already handles both single tap and long-press
  /// gestures, or when a quick double-tap feels more natural for copying.
  doubleTap,
}
