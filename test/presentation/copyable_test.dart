import 'package:copyable_widget/copyable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Copyable widget', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'test-value',
            feedback: CopyableFeedback.none(),
            child: Text('Hello'),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('tap mode triggers on tap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'copied',
            mode: CopyableActionMode.tap,
            feedback: CopyableFeedback.snackBar(text: 'Tap works'),
            child: Text('tap me'),
          ),
        ),
      );

      await tester.tap(find.text('tap me'));
      await tester.pump();

      expect(find.text('Tap works'), findsOneWidget);
    });

    testWidgets('longPress mode triggers on long press', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'copied',
            mode: CopyableActionMode.longPress,
            feedback: CopyableFeedback.snackBar(text: 'LongPress works'),
            child: Text('hold me'),
          ),
        ),
      );

      await tester.longPress(find.text('hold me'));
      await tester.pump();

      expect(find.text('LongPress works'), findsOneWidget);
    });

    testWidgets('tap does NOT trigger on longPress mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'x',
            mode: CopyableActionMode.longPress,
            feedback: CopyableFeedback.snackBar(text: 'Should not appear'),
            child: Text('widget'),
          ),
        ),
      );

      await tester.tap(find.text('widget'));
      await tester.pump();

      expect(find.text('Should not appear'), findsNothing);
    });

    testWidgets('none feedback shows no SnackBar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'x',
            mode: CopyableActionMode.tap,
            feedback: CopyableFeedback.none(),
            child: Text('silent'),
          ),
        ),
      );

      await tester.tap(find.text('silent'));
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('custom feedback callback is invoked', (tester) async {
      String? capturedValue;

      await tester.pumpWidget(
        _wrap(
          Copyable(
            value: 'wallet-addr',
            mode: CopyableActionMode.tap,
            feedback: CopyableFeedback.custom(
              (_, event) => capturedValue = event.value,
            ),
            child: const Text('custom'),
          ),
        ),
      );

      await tester.tap(find.text('custom'));
      await tester.pump();

      expect(capturedValue, 'wallet-addr');
    });
  });

  group('Copyable.text factory', () {
    testWidgets('renders the supplied text string', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Copyable.text(
            'TXN-001',
            mode: CopyableActionMode.tap,
            feedback: const CopyableFeedback.none(),
          ),
        ),
      );

      expect(find.text('TXN-001'), findsOneWidget);
    });

    testWidgets('shows SnackBar on tap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Copyable.text(
            'TXN-002',
            mode: CopyableActionMode.tap,
            feedback: const CopyableFeedback.snackBar(text: 'Text copied'),
          ),
        ),
      );

      await tester.tap(find.text('TXN-002'));
      await tester.pump();

      expect(find.text('Text copied'), findsOneWidget);
    });

    testWidgets('forwards TextStyle to underlying Text', (tester) async {
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        _wrap(
          Copyable.text(
            'styled',
            mode: CopyableActionMode.tap,
            feedback: const CopyableFeedback.none(),
            style: style,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('styled'));
      expect(textWidget.style?.fontSize, 24);
    });
  });

  group('CopyableEvent', () {
    test('equality holds for identical values', () {
      final ts = DateTime(2026);
      final a = CopyableEvent(
        value: 'x',
        timestamp: ts,
        mode: CopyableActionMode.tap,
      );
      final b = CopyableEvent(
        value: 'x',
        timestamp: ts,
        mode: CopyableActionMode.tap,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes value and mode', () {
      final event = CopyableEvent(
        value: 'abc',
        timestamp: DateTime(2026),
        mode: CopyableActionMode.longPress,
      );

      expect(event.toString(), contains('abc'));
      expect(event.toString(), contains('longPress'));
    });
  });
}
