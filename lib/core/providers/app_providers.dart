import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../currency/currency_formatter.dart';
import '../currency/currency_registry.dart';
import '../currency/exchange_rate_service.dart';

const localePreferenceKey = 'preferred_language';
const onboardingCompleteKey = 'onboarding_complete';
const countryPreferenceKey = 'selected_country_code';
const currencyPreferenceKey = 'preferred_currency_code';

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

final selectedCountryProvider =
    StateNotifierProvider<SelectedCountryController, String?>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return SelectedCountryController(preferences, ref);
    });

class SelectedCountryController extends StateNotifier<String?> {
  SelectedCountryController(this._preferences, this._ref)
    : super(_preferences.getString(countryPreferenceKey));

  final SharedPreferences _preferences;
  final Ref _ref;

  Future<void> setCountry(CountrySpec country) async {
    await _preferences.setString(countryPreferenceKey, country.code);
    state = country.code;
    await _ref
        .read(preferredCurrencyProvider.notifier)
        .setCurrency(country.defaultCurrencyCode);
  }
}

final preferredCurrencyProvider =
    StateNotifierProvider<PreferredCurrencyController, String>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return PreferredCurrencyController(preferences);
    });

class PreferredCurrencyController extends StateNotifier<String> {
  PreferredCurrencyController(this._preferences)
    : super(
        _preferences.getString(currencyPreferenceKey) ??
            CurrencyRegistry.defaultCurrencyCode,
      );

  final SharedPreferences _preferences;

  Future<void> setCurrency(String currencyCode) async {
    final normalized = CurrencyRegistry.currencyByCode(currencyCode).code;
    await _preferences.setString(currencyPreferenceKey, normalized);
    state = normalized;
  }
}

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return ExchangeRateService(preferences: preferences);
});

final exchangeRatesProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(exchangeRateServiceProvider).getRates();
});

final formatUsdProvider = Provider<String Function(double usdAmount)>((ref) {
  final currencyCode = ref.watch(preferredCurrencyProvider);
  final rates =
      ref.watch(exchangeRatesProvider).valueOrNull ??
      CurrencyRegistry.fallbackRates;
  return (usdAmount) => CurrencyFormatter.formatFromUsd(
    usdAmount,
    currencyCode: currencyCode,
    rates: rates,
  );
});
