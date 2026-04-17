import 'package:car_rental_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CarShare boots to login', (WidgetTester tester) async {
    await tester.pumpWidget(const CarShareApp());
    await tester.pump();

    expect(find.text('CarShare'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });
}
