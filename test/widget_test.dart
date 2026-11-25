import 'package:aura_deck/app.dart';
import 'package:aura_deck/core/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starts with localized onboarding and language choices', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({localePreferenceKey: 'es'});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const AuraDeckApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Elige tu idioma'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
  });
}
