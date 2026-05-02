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

void _mockPlatformChannelCapture(WidgetTester tester, List<String> written) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        written.add(call.arguments['text'] as String);
      }
      return null;
    },
  );
}

void _mockPlatformChannelThrow(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        throw PlatformException(code: 'CLIPBOARD_ERROR');
      }
      return null;
    },
  );
}

void main() {
  group('CopyableText', () {
    testWidgets('onError is called when clipboard write fails', (tester) async {
      _mockPlatformChannelThrow(tester);
      Object? capturedError;
      await tester.pumpWidget(
        _wrap(
          CopyableText(
            'tap',
            mode: CopyableActionMode.tap,
            feedback: const SnackBarFeedback(text: 'Should not appear'),
            onError: (e) => capturedError = e,
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(capturedError, isNotNull);
      expect(find.text('Should not appear'), findsNothing);
    });

    testWidgets('no feedback shown when onError fires', (tester) async {
      _mockPlatformChannelThrow(tester);
      await tester.pumpWidget(
        _wrap(
          CopyableText(
            'tap',
            mode: CopyableActionMode.tap,
            feedback: const SnackBarFeedback(text: 'Copied'),
            onError: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('clears clipboard after specified duration', (tester) async {
      final written = <String>[];
      _mockPlatformChannelCapture(tester, written);
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'tap',
            clearAfter: Duration(seconds: 30),
            feedback: NoneFeedback(),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(written, ['tap']);

      await tester.pump(const Duration(seconds: 30));
      expect(written, ['tap', '']);
    });

    testWidgets('does NOT clear clipboard when onError fires', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'CLIPBOARD_ERROR');
          }
          return null;
        },
      );
      await tester.pumpWidget(
        _wrap(
          CopyableText(
            'tap',
            clearAfter: const Duration(seconds: 30),
            feedback: const NoneFeedback(),
            onError: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
    });

    testWidgets('uses theme clearAfter when widget clearAfter is null',
        (tester) async {
      final written = <String>[];
      _mockPlatformChannelCapture(tester, written);
      await tester.pumpWidget(
        _wrap(
          const CopyableTheme(
            data: CopyableThemeData(
              clearAfter: Duration(seconds: 15),
            ),
            child: CopyableText(
              'tap',
              feedback: NoneFeedback(),
            ),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(written, ['tap']);

      await tester.pump(const Duration(seconds: 15));
      expect(written, ['tap', '']);
    });

    testWidgets('onCopied callback fires with correct event', (tester) async {
      _mockPlatformChannel(tester);
      CopyableEvent? firedEvent;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CopyableText(
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

    testWidgets('doubleTap mode triggers on double tap', (tester) async {
      _mockPlatformChannel(tester);
      CopyableEvent? firedEvent;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CopyableText(
            'double',
            mode: CopyableActionMode.doubleTap,
            feedback: const NoneFeedback(),
            onCopied: (event) => firedEvent = event,
          ),
        ),
      ));

      await tester.tap(find.text('double'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('double'));
      await tester.pumpAndSettle();

      expect(firedEvent, isNotNull);
      expect(firedEvent!.mode, CopyableActionMode.doubleTap);
    });
  });

  group('CopyableText trailingHint', () {
    testWidgets('shows copy icon when trailingHint is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'TXN-123',
            trailingHint: true,
            feedback: NoneFeedback(),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.text('TXN-123'), findsOneWidget);
    });

    testWidgets('does not show icon when trailingHint is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'TXN-123',
            feedback: NoneFeedback(),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsNothing);
    });

    testWidgets('icon switches to check after copy', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'TXN-123',
            trailingHint: true,
            feedback: NoneFeedback(),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.text('TXN-123'));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsNothing);
    });

    testWidgets('check icon resets to copy icon after 2 seconds', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'TXN-123',
            trailingHint: true,
            feedback: NoneFeedback(),
          ),
        ),
      );

      await tester.tap(find.text('TXN-123'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('Copyable.text forwards trailingHint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Copyable.text(
            'TXN-456',
            trailingHint: true,
            feedback: const CopyableFeedback.none(),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.text('TXN-456'), findsOneWidget);
    });
  });

  group('CopyableText semantics', () {
    testWidgets('wraps with Semantics button role', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'test',
            feedback: NoneFeedback(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableText));
      expect(semantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('auto-generates semantic label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'TXN-123',
            feedback: NoneFeedback(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableText));
      expect(semantics.label, contains('Copy TXN-123'));
    });

    testWidgets('uses custom semanticLabel', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'Copy card',
            value: '4111-1111-1111-1111',
            semanticLabel: 'Copy card number',
            feedback: NoneFeedback(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableText));
      expect(semantics.label, contains('Copy card number'));
    });

    testWidgets('uses value (not data) for auto-generated label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'Show label',
            value: 'secret-value',
            feedback: NoneFeedback(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableText));
      expect(semantics.label, contains('Copy secret-value'));
    });
  });

  group('CopyableText cursor', () {
    testWidgets('renders MouseRegion with click cursor', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'hover me',
            feedback: NoneFeedback(),
          ),
        ),
      );

      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(CopyableText),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(mouseRegion.cursor, SystemMouseCursors.click);
    });
  });

  group('CopyableText trailingHint with separate value', () {
    testWidgets('copies value (not data) when trailingHint is active', (tester) async {
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
          const CopyableText(
            'Show label',
            value: 'actual-secret',
            trailingHint: true,
            feedback: NoneFeedback(),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      await tester.tap(find.text('Show label'));
      await tester.pumpAndSettle();
      expect(clipboardValue, 'actual-secret');
    });
  });

  group('CopyableText trailingHint icon styling', () {
    testWidgets('icon has size 16', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'TXN',
            trailingHint: true,
            feedback: NoneFeedback(),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.copy_rounded));
      expect(icon.size, 16);
    });
  });

  group('CopyableText disposal', () {
    testWidgets('disposing mid-hint-reset timer does not throw', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          const CopyableText(
            'tap',
            trailingHint: true,
            feedback: NoneFeedback(),
          ),
        ),
      );

      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
