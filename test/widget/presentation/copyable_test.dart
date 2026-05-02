import 'package:copyable_widget/copyable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Registers a no-op mock for [SystemChannels.platform] so that
/// [Clipboard.setData] and [HapticFeedback] calls complete successfully
/// instead of throwing [MissingPluginException] in the test environment.
void _mockPlatformChannel(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async => null,
  );
}

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
      _mockPlatformChannel(tester);
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
      await tester.pump();

      expect(find.text('Tap works'), findsOneWidget);
    });

    testWidgets('longPress mode triggers on long press', (tester) async {
      _mockPlatformChannel(tester);
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

    testWidgets('doubleTap mode triggers on double tap', (tester) async {
      _mockPlatformChannel(tester);
      String? clipboardValue;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardValue = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'double-value',
            mode: CopyableActionMode.doubleTap,
            feedback: CopyableFeedback.none(),
            child: Text('double tap me'),
          ),
        ),
      );

      await tester.tap(find.text('double tap me'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('double tap me'));
      await tester.pumpAndSettle();

      expect(clipboardValue, 'double-value');
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
      _mockPlatformChannel(tester);
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
      _mockPlatformChannel(tester);
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
      await tester.pump();

      expect(find.text('Text copied'), findsOneWidget);
    });

    testWidgets('value is what lands on the clipboard, not the label', (tester) async {
      String? clipboardValue;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardValue = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        _wrap(
          Copyable.text(
            'Copy card number',
            value: '4111-1111-1111-1111',
            mode: CopyableActionMode.tap,
            feedback: const CopyableFeedback.none(),
          ),
        ),
      );

      await tester.tap(find.text('Copy card number'));
      await tester.pump();

      expect(clipboardValue, '4111-1111-1111-1111');
    });

    testWidgets('displays label text when value is provided separately', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Copyable.text(
            'Copy card number',
            value: '4111-1111-1111-1111',
            mode: CopyableActionMode.tap,
            feedback: const CopyableFeedback.none(),
          ),
        ),
      );

      expect(find.text('Copy card number'), findsOneWidget);
      expect(find.text('4111-1111-1111-1111'), findsNothing);
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

  group('Copyable semantics', () {
    testWidgets('wraps child with Semantics button role', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'test',
            feedback: CopyableFeedback.none(),
            child: Text('tap me'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('auto-generates semantic label from value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'TXN-123',
            feedback: CopyableFeedback.none(),
            child: Text('tap'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.label, contains('Copy TXN-123'));
    });

    testWidgets('uses custom semanticLabel when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: '4111-1111-1111-1111',
            semanticLabel: 'Copy card number',
            feedback: CopyableFeedback.none(),
            child: Text('tap'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.label, contains('Copy card number'));
    });

    testWidgets('truncates auto-generated label for long values', (tester) async {
      final longValue = 'A' * 100;
      await tester.pumpWidget(
        _wrap(
          Copyable(
            value: longValue,
            feedback: const CopyableFeedback.none(),
            child: const Text('tap'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.label, startsWith('Copy '));
      expect(semantics.label.length, lessThan(60));
    });
  });

  group('Copyable cursor', () {
    testWidgets('renders MouseRegion with click cursor', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'test',
            feedback: CopyableFeedback.none(),
            child: Text('hover me'),
          ),
        ),
      );

      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(Copyable),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(mouseRegion.cursor, SystemMouseCursors.click);
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

  group('Copyable.icon factory', () {
    testWidgets('renders icon and copies value on tap', (tester) async {
      String? clipboardValue;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardValue = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        _wrap(
          Copyable.icon(
            'secret-value',
            feedback: const CopyableFeedback.none(),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();
      expect(clipboardValue, 'secret-value');
    });

    testWidgets('forwards semanticLabel', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Copyable.icon(
            'addr',
            semanticLabel: 'Copy wallet address',
            feedback: const CopyableFeedback.none(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.label, contains('Copy wallet address'));
    });
  });

  group('Copyable excludeSemantics', () {
    testWidgets('excludes child semantics when true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'test',
            excludeSemantics: true,
            semanticLabel: 'Copy test',
            feedback: CopyableFeedback.none(),
            child: Text('child text'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.label, isNot(contains('child text')));
    });

    testWidgets('includes child semantics when false (default)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'test',
            semanticLabel: 'Copy test',
            feedback: CopyableFeedback.none(),
            child: Text('child text'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(Copyable));
      expect(semantics.label, contains('child text'));
    });
  });

  group('Copyable widget disposal', () {
    testWidgets('disposing mid-clearAfter timer does not throw', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'x',
            clearAfter: Duration(seconds: 30),
            feedback: CopyableFeedback.none(),
            child: Text('tap'),
          ),
        ),
      );

      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump(const Duration(seconds: 30));
    });
  });
}
