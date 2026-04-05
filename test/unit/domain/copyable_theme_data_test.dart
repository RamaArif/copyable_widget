import 'package:copyable_widget/copyable_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CopyableThemeData', () {
    test('has correct defaults', () {
      const data = CopyableThemeData();
      expect(data.snackBarText, 'Copied!');
      expect(data.snackBarDuration, const Duration(seconds: 2));
      expect(data.clearAfter, isNull);
    });

    test('copyWith overrides snackBarText', () {
      const data = CopyableThemeData();
      final copy = data.copyWith(snackBarText: 'Done!');
      expect(copy.snackBarText, 'Done!');
      expect(copy.snackBarDuration, const Duration(seconds: 2));
      expect(copy.clearAfter, isNull);
    });

    test('copyWith overrides snackBarDuration', () {
      const data = CopyableThemeData();
      final copy = data.copyWith(snackBarDuration: const Duration(seconds: 5));
      expect(copy.snackBarDuration, const Duration(seconds: 5));
      expect(copy.snackBarText, 'Copied!');
    });

    test('copyWith overrides clearAfter', () {
      const data = CopyableThemeData();
      final copy = data.copyWith(clearAfter: const Duration(seconds: 30));
      expect(copy.clearAfter, const Duration(seconds: 30));
    });

    test('copyWith with no args returns identical values', () {
      const data = CopyableThemeData(
        snackBarText: 'Hi',
        snackBarDuration: Duration(seconds: 3),
        clearAfter: Duration(seconds: 10),
      );
      final copy = data.copyWith();
      expect(copy.snackBarText, 'Hi');
      expect(copy.snackBarDuration, const Duration(seconds: 3));
      expect(copy.clearAfter, const Duration(seconds: 10));
    });

    test('copyWith(clearAfter: null) disables clearAfter', () {
      const data = CopyableThemeData(clearAfter: Duration(seconds: 30));
      final copy = data.copyWith(clearAfter: null);
      expect(copy.clearAfter, isNull);
    });

    test('copyWith omitting clearAfter retains existing value', () {
      const data = CopyableThemeData(clearAfter: Duration(seconds: 30));
      final copy = data.copyWith(snackBarText: 'Updated');
      expect(copy.clearAfter, const Duration(seconds: 30));
      expect(copy.snackBarText, 'Updated');
    });
  });
}
