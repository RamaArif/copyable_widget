import 'package:copyable_widget/copyable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void _mockPlatformChannel(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async => null,
  );
}

void main() {
  group('v1.3.0 features', () {
    testWidgets('Copyable doubleTap mode triggers on double tap',
        (tester) async {
      _mockPlatformChannel(tester);
      int tapCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Copyable(
            value: 'test',
            mode: CopyableActionMode.doubleTap,
            onCopied: (_) => tapCount++,
            child: const Text('Target'),
          ),
        ),
      ));

      final target = find.text('Target');
      await tester.tap(target);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1)); // Clear gesture arena
      expect(tapCount, 0, reason: 'Single tap should not trigger copy');

      await tester.longPress(target);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1)); // Clear gesture arena
      expect(tapCount, 0, reason: 'Long press should not trigger copy');

      await tester.tap(target);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(tapCount, 1, reason: 'Double tap should trigger copy once');
    });

    testWidgets('Copyable.icon renders Icon and copies', (tester) async {
      _mockPlatformChannel(tester);
      int tapCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Copyable.icon(
            'test',
            icon: Icons.abc,
            size: 42,
            color: Colors.red,
            onCopied: (_) => tapCount++,
          ),
        ),
      ));

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);
      final Icon icon = tester.widget(iconFinder);
      expect(icon.icon, Icons.abc);
      expect(icon.size, 42);
      expect(icon.color, Colors.red);

      await tester.tap(iconFinder);
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });

    testWidgets('Copyable onCopied callback fires with correct event',
        (tester) async {
      _mockPlatformChannel(tester);
      CopyableEvent? firedEvent;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Copyable(
            value: 'hello',
            onCopied: (event) => firedEvent = event,
            child: const Text('Target'),
          ),
        ),
      ));

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();

      expect(firedEvent, isNotNull);
      expect(firedEvent!.value, 'hello');
      expect(firedEvent!.mode, CopyableActionMode.tap);
    });

    testWidgets('CopyableText onCopied callback fires with correct event',
        (tester) async {
      _mockPlatformChannel(tester);
      CopyableEvent? firedEvent;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Copyable.text(
            'hello',
            onCopied: (event) => firedEvent = event,
          ),
        ),
      ));

      await tester.tap(find.text('hello'));
      await tester.pumpAndSettle();

      expect(firedEvent, isNotNull);
      expect(firedEvent!.value, 'hello');
      expect(firedEvent!.mode, CopyableActionMode.tap);
    });
  });
}
