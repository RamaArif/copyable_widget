import 'package:copyable_widget/copyable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void _mockPlatformChannel(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async => null,
  );
}

void main() {
  group('CopyableTheme', () {
    testWidgets('of(context) returns defaults when no theme in tree',
        (tester) async {
      CopyableThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = CopyableTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured!.snackBarText, 'Copied!');
      expect(captured!.snackBarDuration, const Duration(seconds: 2));
      expect(captured!.clearAfter, isNull);
    });

    testWidgets('of(context) returns nearest ancestor theme data',
        (tester) async {
      CopyableThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: CopyableTheme(
            data: const CopyableThemeData(snackBarText: 'Copied!'),
            child: Builder(
              builder: (context) {
                captured = CopyableTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(captured!.snackBarText, 'Copied!');
    });

    testWidgets('Copyable uses theme snackBarText when feedback has null text',
        (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          const CopyableTheme(
            data: CopyableThemeData(snackBarText: 'Theme copied!'),
            child: Copyable(
              value: 'x',
              mode: CopyableActionMode.tap,
              feedback: SnackBarFeedback(),
              child: Text('tap'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Theme copied!'), findsOneWidget);
    });

    testWidgets('nested theme overrides parent theme', (tester) async {
      CopyableThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: CopyableTheme(
            data: const CopyableThemeData(
              snackBarText: 'Parent',
              clearAfter: Duration(seconds: 30),
            ),
            child: CopyableTheme(
              data: const CopyableThemeData(snackBarText: 'Child'),
              child: Builder(
                builder: (context) {
                  captured = CopyableTheme.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(captured!.snackBarText, 'Child');
      expect(captured!.clearAfter, isNull);
    });
  });
}
