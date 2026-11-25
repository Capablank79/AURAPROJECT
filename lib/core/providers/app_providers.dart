import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

const localePreferenceKey = 'preferred_language';
const onboardingCompleteKey = 'onboarding_complete';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden.'),
);

final appLocaleProvider = StateNotifierProvider<AppLocaleController, Locale>((
  ref,
) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return AppLocaleController(
    preferences,
    WidgetsBinding.instance.platformDispatcher.locale,
  );
});

class AppLocaleController extends StateNotifier<Locale> {
  AppLocaleController(this._preferences, Locale systemLocale)
    : super(
        _initialLocale(
          _preferences.getString(localePreferenceKey),
          systemLocale,
        ),
      );

  final SharedPreferences _preferences;

  Future<void> setLocale(Locale locale) async {
    if (!AppConstants.supportedLanguageCodes.contains(locale.languageCode)) {
      throw ArgumentError.value(
        locale.languageCode,
        'locale',
        'Unsupported language.',
      );
    }

    await _preferences.setString(localePreferenceKey, locale.languageCode);
    state = locale;
  }

  static Locale _initialLocale(String? savedCode, Locale systemLocale) {
    final candidate = savedCode ?? systemLocale.languageCode;
    final languageCode = AppConstants.supportedLanguageCodes.contains(candidate)
        ? candidate
        : 'en';
    return Locale(languageCode);
  }
}
