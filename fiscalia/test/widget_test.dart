import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FiscalIAApp());
    expect(find.text('FiscalIA'), findsOneWidget);
  });
}
