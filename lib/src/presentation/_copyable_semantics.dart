import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Auto-generates a semantic label for screen readers from the copy value.
String copyableAutoLabel(String value) {
  final truncated = value.length > 50 ? '${value.substring(0, 47)}...' : value;
  return 'Copy $truncated';
}

/// Announces a successful copy to assistive technology.
void announceCopied(BuildContext context) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    'Copied',
    Directionality.of(context),
  );
}
