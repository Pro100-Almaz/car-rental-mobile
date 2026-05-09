import 'package:car_rental_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AutoFleet boots to splash', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoFleetApp());
    await tester.pump();

    expect(find.text('AutoFleet'), findsWidgets);
  });
}
