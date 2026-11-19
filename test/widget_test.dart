import 'package:flutter_test/flutter_test.dart';
import 'package:mangis/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the Mangis profile onboarding on first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MangisApp(initialProfile: null));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bienvenido a Mangis'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
  });
}
