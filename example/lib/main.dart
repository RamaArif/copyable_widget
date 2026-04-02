import 'package:copyable_widget/copyable_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CopyableExampleApp());
}

class CopyableExampleApp extends StatelessWidget {
  const CopyableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'copyable_widget demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool _silentCopied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('copyable_widget'),
        centerTitle: false,
        backgroundColor: cs.surfaceContainerHighest,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _SectionLabel('1 — Copyable.text (default SnackBar)'),
          const SizedBox(height: 8),
          _DemoCard(
            description:
                'Long-press on mobile, tap on desktop/web. Shows "Copied!" SnackBar.',
            child: Copyable.text(
              'TXN-9182736',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel('2 — Copyable widget (wraps any child)'),
          const SizedBox(height: 8),
          _DemoCard(
            description:
                'The copy value and the displayed widget are decoupled.',
            child: Copyable(
              value: 'GB29 NWBK 6016 1331 9268 19',
              child: _AccountNumberRow(
                label: 'IBAN',
                number: 'GB29 NWBK 6016 1331 9268 19',
              ),
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel('3 — Custom SnackBar message'),
          const SizedBox(height: 8),
          _DemoCard(
            description:
                'Pass a custom text to CopyableFeedback.snackBar().',
            child: Copyable.text(
              'PROMO-SAVE20',
              feedback:
                  const CopyableFeedback.snackBar(text: 'Promo code copied!'),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel('4 — Fully custom feedback'),
          const SizedBox(height: 8),
          _DemoCard(
            description:
                'CopyableFeedback.custom() gives you BuildContext + CopyableEvent.',
            child: Copyable(
              value: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
              feedback: CopyableFeedback.custom(
                (context, event) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Copied: ${event.value.substring(0, 8)}… '
                      '(via ${event.mode.name})',
                    ),
                  ),
                ),
              ),
              child: _WalletAddressRow(
                address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
              ),
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel('5 — Silent copy (no UI feedback)'),
          const SizedBox(height: 8),
          _DemoCard(
            description:
                'CopyableFeedback.none() — app manages its own state indicator.',
            child: Copyable(
              value: 'sk_live_abc123def456',
              feedback: CopyableFeedback.none(),
              mode: CopyableActionMode.tap,
              child: GestureDetector(
                onTap: () => setState(() => _silentCopied = true),
                child: _ApiKeyRow(
                  apiKey: 'sk_live_abc123def456',
                  copied: _silentCopied,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel('6 — Tap vs Long-press (explicit mode)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DemoCard(
                  description: 'tap',
                  child: Copyable(
                    value: 'tap-mode',
                    mode: CopyableActionMode.tap,
                    feedback: const CopyableFeedback.snackBar(
                      text: 'Tap mode: copied!',
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              color: cs.primary, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Tap me',
                            style: TextStyle(color: cs.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DemoCard(
                  description: 'longPress',
                  child: Copyable(
                    value: 'long-press-mode',
                    mode: CopyableActionMode.longPress,
                    feedback: const CopyableFeedback.snackBar(
                      text: 'Long-press mode: copied!',
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pan_tool_rounded,
                              color: cs.secondary, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Hold me',
                            style: TextStyle(color: cs.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.description, required this.child});
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountNumberRow extends StatelessWidget {
  const _AccountNumberRow({required this.label, required this.number});
  final String label;
  final String number;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.account_balance_rounded, color: cs.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.outline)),
            Text(number,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                )),
          ],
        ),
        const Spacer(),
        Icon(Icons.copy_rounded, color: cs.outline, size: 18),
      ],
    );
  }
}

class _WalletAddressRow extends StatelessWidget {
  const _WalletAddressRow({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final short =
        '${address.substring(0, 8)}…${address.substring(address.length - 6)}';
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.currency_bitcoin_rounded,
              color: cs.secondary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wallet address',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.outline)),
            Text(short,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                )),
          ],
        ),
        const Spacer(),
        Icon(Icons.copy_rounded, color: cs.outline, size: 18),
      ],
    );
  }
}

class _ApiKeyRow extends StatelessWidget {
  const _ApiKeyRow({required this.apiKey, required this.copied});
  final String apiKey;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.key_rounded, color: cs.tertiary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            apiKey,
            style: TextStyle(
              fontFamily: 'monospace',
              color: cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: copied
              ? Icon(Icons.check_circle_rounded,
                  key: const ValueKey('check'), color: Colors.green, size: 20)
              : Icon(Icons.copy_rounded,
                  key: const ValueKey('copy'), color: cs.outline, size: 18),
        ),
      ],
    );
  }
}
