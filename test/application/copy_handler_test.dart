import 'package:copyable_widget/copyable_widget.dart';
import 'package:copyable_widget/src/application/copy_handler.dart';
import 'package:copyable_widget/src/domain/services/clipboard_service.dart';
import 'package:copyable_widget/src/domain/services/haptic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Mock implementations ─────────────────────────────────────────────────────

class _MockClipboardService implements ClipboardService {
  String? lastCopied;

  @override
  Future<void> copy(String value) async {
    lastCopied = value;
  }
}

class _MockHapticService implements HapticService {
  HapticFeedbackStyle? lastStyle;

  @override
  Future<void> perform(HapticFeedbackStyle style) async {
    lastStyle = style;
  }
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('CopyHandler.resolveMode', () {
    late CopyHandler handler;

    setUp(() {
      handler = CopyHandler(
        clipboardService: _MockClipboardService(),
        hapticService: _MockHapticService(),
      );
    });

    test('returns explicit tap mode unchanged', () {
      expect(
        handler.resolveMode(CopyableActionMode.tap),
        CopyableActionMode.tap,
      );
    });

    test('returns explicit longPress mode unchanged', () {
      expect(
        handler.resolveMode(CopyableActionMode.longPress),
        CopyableActionMode.longPress,
      );
    });

    test('resolves null to tap on all platforms', () {
      expect(handler.resolveMode(null), CopyableActionMode.tap);
    });
  });

  group('CopyHandler.handle', () {
    late _MockClipboardService clipboard;
    late _MockHapticService haptic;
    late CopyHandler handler;

    setUp(() {
      clipboard = _MockClipboardService();
      haptic = _MockHapticService();
      handler = CopyHandler(
        clipboardService: clipboard,
        hapticService: haptic,
      );
    });

    testWidgets('writes value to clipboard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => handler.handle(
                    context: context,
                    value: 'TXN-123',
                    resolvedMode: CopyableActionMode.tap,
                    feedback: const CopyableFeedback.none(),
                    haptic: HapticFeedbackStyle.lightImpact,
                  ),
                  child: const Text('copy'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('copy'));
      await tester.pump();

      expect(clipboard.lastCopied, 'TXN-123');
    });

    testWidgets('fires haptic with correct style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => handler.handle(
                    context: context,
                    value: 'x',
                    resolvedMode: CopyableActionMode.tap,
                    feedback: const CopyableFeedback.none(),
                    haptic: HapticFeedbackStyle.heavyImpact,
                  ),
                  child: const Text('copy'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('copy'));
      await tester.pump();

      expect(haptic.lastStyle, HapticFeedbackStyle.heavyImpact);
    });

    testWidgets('shows SnackBar for snackBar feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => handler.handle(
                    context: context,
                    value: 'hello',
                    resolvedMode: CopyableActionMode.tap,
                    feedback: const CopyableFeedback.snackBar(text: 'Done!'),
                    haptic: HapticFeedbackStyle.lightImpact,
                  ),
                  child: const Text('copy'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('copy'));
      await tester.pump();

      expect(find.text('Done!'), findsOneWidget);
    });

    testWidgets('calls custom feedback callback with event', (tester) async {
      CopyableEvent? capturedEvent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => handler.handle(
                    context: context,
                    value: 'secret',
                    resolvedMode: CopyableActionMode.longPress,
                    feedback: CopyableFeedback.custom(
                      (_, event) => capturedEvent = event,
                    ),
                    haptic: HapticFeedbackStyle.lightImpact,
                  ),
                  child: const Text('copy'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('copy'));
      await tester.pump();

      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.value, 'secret');
      expect(capturedEvent!.mode, CopyableActionMode.longPress);
    });

    testWidgets('none feedback fires no SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => handler.handle(
                    context: context,
                    value: 'x',
                    resolvedMode: CopyableActionMode.tap,
                    feedback: const CopyableFeedback.none(),
                    haptic: HapticFeedbackStyle.lightImpact,
                  ),
                  child: const Text('copy'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('copy'));
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
