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

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  static const _cardNumber = '4111 1111 1111 1111';
  static const _iban = 'GB29 NWBK 6016 1331 9268 19';
  static const _accountNumber = 'DE89 3704 0044 0532 0130 00';

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
          // ── 1. Copyable.text with value ──────────────────────────────────
          const _SectionLabel('Copyable.text — label + value'),
          const SizedBox(height: 8),
          _DemoCard(
            description:
                'The label "Copy card number" is displayed; the actual '
                'card number is what lands on the clipboard.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cardNumber,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Copyable.text(
                  'Copy card number',
                  value: _cardNumber,
                  feedback: const CopyableFeedback.snackBar(
                    text: 'Card number copied!',
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── 2. Whole row copyable ────────────────────────────────────────
          const _SectionLabel('Copyable — whole row'),
          const SizedBox(height: 8),
          const _DemoCard(
            description:
                'Wrap the entire row — tap anywhere on it to copy.',
            child: _IbanRow(iban: _iban),
          ),
          const SizedBox(height: 24),

          // ── 3. Only the copy icon is copyable ────────────────────────────
          const _SectionLabel('Copyable — icon only'),
          const SizedBox(height: 8),
          const _DemoCard(
            description:
                'Only the copy icon is wrapped with Copyable — the rest '
                'of the row is not interactive.',
            child: _IbanRowIconOnly(iban: _accountNumber),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _IbanRow extends StatelessWidget {
  const _IbanRow({required this.iban});
  final String iban;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Copyable(
      value: iban,
      feedback: const CopyableFeedback.snackBar(text: 'IBAN copied!'),
      child: Row(
        children: [
          Icon(Icons.account_balance_rounded, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IBAN',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.outline),
              ),
              Text(
                iban,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.copy_rounded, color: cs.outline, size: 18),
        ],
      ),
    );
  }
}

class _IbanRowIconOnly extends StatelessWidget {
  const _IbanRowIconOnly({required this.iban});
  final String iban;

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
            Text(
              'IBAN',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.outline),
            ),
            Text(
              iban,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const Spacer(),
        Copyable(
          value: iban,
          feedback: const CopyableFeedback.snackBar(text: 'IBAN copied!'),
          child: Icon(Icons.copy_rounded, color: cs.outline, size: 18),
        ),
      ],
    );
  }
}

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
