import 'package:flutter_test/flutter_test.dart';
import 'package:homebase/app.dart';

void main() {
  testWidgets('App renders with bottom navigation', (tester) async {
    await tester.pumpWidget(const HomebaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Inventory'), findsWidgets);
    expect(find.text('Automation'), findsWidgets);
    expect(find.text('Alerts'), findsWidgets);
  });
}
