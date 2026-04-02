import 'package:flutter_test/flutter_test.dart';

import 'package:copyable_widget_example/main.dart';

void main() {
  testWidgets('CopyableExampleApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CopyableExampleApp());
    expect(find.text('copyable'), findsOneWidget);
  });
}
