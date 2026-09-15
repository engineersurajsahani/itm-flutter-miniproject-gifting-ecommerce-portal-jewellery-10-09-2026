import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:luxury_jewellery/main.dart';
import 'package:luxury_jewellery/providers/shop_provider.dart';

void main() {
  testWidgets('Aurelia App Brand Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ShopProvider()),
        ],
        child: const AureliaMaisonApp(),
      ),
    );

    // Verify that Aurelia logo or name is there in the splash or initial screen.
    expect(find.text('AURELIA'), findsWidgets);
  });
}
