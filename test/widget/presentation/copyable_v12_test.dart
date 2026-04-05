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

void _mockPlatformChannelCapture(
    WidgetTester tester, List<String> written) {
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
            data: const CopyableThemeData(snackBarText: 'Copied ✓'),
            child: Builder(
              builder: (context) {
                captured = CopyableTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(captured!.snackBarText, 'Copied ✓');
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
  });

  group('Copyable onError', () {
    testWidgets('onError is called when clipboard write fails', (tester) async {
      _mockPlatformChannelThrow(tester);
      Object? capturedError;
      await tester.pumpWidget(
        _wrap(
          Copyable(
            value: 'secret',
            mode: CopyableActionMode.tap,
            feedback: const SnackBarFeedback(text: 'Should not appear'),
            onError: (e) => capturedError = e,
            child: const Text('tap'),
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
          Copyable(
            value: 'x',
            mode: CopyableActionMode.tap,
            feedback: const SnackBarFeedback(text: 'Copied'),
            onError: (_) {},
            child: const Text('tap'),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('Copyable clearAfter', () {
    testWidgets('clears clipboard after specified duration', (tester) async {
      final written = <String>[];
      _mockPlatformChannelCapture(tester, written);
      await tester.pumpWidget(
        _wrap(
          const Copyable(
            value: 'secret',
            clearAfter: Duration(seconds: 30),
            feedback: NoneFeedback(),
            child: Text('tap'),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(written, ['secret']);

      await tester.pump(const Duration(seconds: 30));
      expect(written, ['secret', '']);
    });

    testWidgets('does NOT clear clipboard when onError fires', (tester) async {
      final written = <String>[];
      _mockPlatformChannelCapture(tester, written);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final text = call.arguments['text'] as String;
            written.add(text);
            throw PlatformException(code: 'CLIPBOARD_ERROR');
          }
          return null;
        },
      );
      await tester.pumpWidget(
        _wrap(
          Copyable(
            value: 'secret',
            clearAfter: const Duration(seconds: 30),
            feedback: const NoneFeedback(),
            onError: (_) {},
            child: const Text('tap'),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      // Only the failed write — no clear timer should fire
      expect(written.where((s) => s == '').toList(), isEmpty);
    });

    testWidgets('uses theme clearAfter when widget clearAfter is null',
        (tester) async {
      final written = <String>[];
      _mockPlatformChannelCapture(tester, written);
      await tester.pumpWidget(
        _wrap(
          const CopyableTheme(
            data: CopyableThemeData(
              clearAfter: Duration(seconds: 10),
            ),
            child: Copyable(
              value: 'data',
              feedback: NoneFeedback(),
              child: Text('tap'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(written, ['data']);

      await tester.pump(const Duration(seconds: 10));
      expect(written, ['data', '']);
    });
  });

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
    testWidgets('renders builder with isCopied=false initially', (tester) async {
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
  });
}
