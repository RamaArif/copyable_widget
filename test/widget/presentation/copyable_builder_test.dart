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
  group('CopyableBuilder clearAfter', () {
    testWidgets('clears clipboard after specified duration', (tester) async {
      final written = <String>[];
      _mockPlatformChannelCapture(tester, written);
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'token',
            clearAfter: const Duration(seconds: 30),
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(written, ['token']);

      await tester.pump(const Duration(seconds: 30));
      expect(written, ['token', '']);
    });
  });

  group('CopyableBuilder', () {
    testWidgets('renders builder with isCopied=false initially',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'x',
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      expect(find.text('idle'), findsOneWidget);
      expect(find.text('copied'), findsNothing);
    });

    testWidgets('isCopied becomes true on tap', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'hello',
            resetAfter: const Duration(seconds: 60),
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(find.text('copied'), findsOneWidget);
    });

    testWidgets('isCopied resets to false after resetAfter', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'hello',
            resetAfter: const Duration(milliseconds: 100),
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(find.text('copied'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('onCopied callback fires with correct event', (tester) async {
      _mockPlatformChannel(tester);
      CopyableEvent? capturedEvent;
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'wallet-addr',
            resetAfter: const Duration(seconds: 60),
            onCopied: (event) => capturedEvent = event,
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.value, 'wallet-addr');
      expect(capturedEvent!.mode, CopyableActionMode.tap);
    });

    testWidgets('onError fires and isCopied stays false on clipboard failure',
        (tester) async {
      _mockPlatformChannelThrow(tester);
      Object? capturedError;
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'x',
            onError: (e) => capturedError = e,
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(capturedError, isNotNull);
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('longPress mode triggers on long press', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'x',
            mode: CopyableActionMode.longPress,
            resetAfter: const Duration(seconds: 60),
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.longPress(find.text('idle'));
      await tester.pump();
      expect(find.text('copied'), findsOneWidget);
    });

    testWidgets('tap does NOT trigger on longPress mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'x',
            mode: CopyableActionMode.longPress,
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('doubleTap mode triggers on double tap', (tester) async {
      _mockPlatformChannel(tester);
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'x',
            mode: CopyableActionMode.doubleTap,
            resetAfter: const Duration(milliseconds: 100),
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );
      await tester.tap(find.text('idle'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('idle'));
      await tester.pump();
      expect(find.text('copied'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
    });
  });

  group('CopyableBuilder semantics', () {
    testWidgets('wraps with Semantics button role', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'test',
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableBuilder));
      expect(semantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('auto-generates semantic label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'wallet-addr',
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableBuilder));
      expect(semantics.label, contains('Copy wallet-addr'));
    });

    testWidgets('uses custom semanticLabel', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'addr',
            semanticLabel: 'Copy wallet address',
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyableBuilder));
      expect(semantics.label, contains('Copy wallet address'));
    });
  });

  group('CopyableBuilder cursor', () {
    testWidgets('renders MouseRegion with click cursor', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyableBuilder(
            value: 'test',
            builder: (_, isCopied) => Text(isCopied ? 'copied' : 'idle'),
          ),
        ),
      );

      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(CopyableBuilder),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(mouseRegion.cursor, SystemMouseCursors.click);
    });
  });
}
