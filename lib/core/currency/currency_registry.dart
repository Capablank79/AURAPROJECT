class CurrencySpec {
  const CurrencySpec({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.fallbackRateFromUsd,
    this.decimals = 2,
  });

  final String code;
  final String symbol;
  final String name;
  final String flag;
  final double fallbackRateFromUsd;
  final int decimals;
}

class CountrySpec {
  const CountrySpec({
    required this.code,
    required this.name,
    required this.flag,
    required this.defaultCurrencyCode,
  });

  final String code;
  final String name;
  final String flag;
  final String defaultCurrencyCode;
}

abstract final class CurrencyRegistry {
  static const String defaultCurrencyCode = 'USD';

  static const List<CurrencySpec> currencies = [
    CurrencySpec(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      flag: '🇺🇸',
      fallbackRateFromUsd: 1.0,
    ),
    CurrencySpec(
      code: 'CLP',
      symbol: '\$',
      name: 'Chilean Peso',
      flag: '🇨🇱',
      fallbackRateFromUsd: 950.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      flag: '🇪🇺',
      fallbackRateFromUsd: 0.92,
    ),
    CurrencySpec(
      code: 'MXN',
      symbol: '\$',
      name: 'Mexican Peso',
      flag: '🇲🇽',
      fallbackRateFromUsd: 20.1,
    ),
    CurrencySpec(
      code: 'ARS',
      symbol: '\$',
      name: 'Argentine Peso',
      flag: '🇦🇷',
      fallbackRateFromUsd: 1005.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'COP',
      symbol: '\$',
      name: 'Colombian Peso',
      flag: '🇨🇴',
      fallbackRateFromUsd: 4350.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'PEN',
      symbol: 'S/',
      name: 'Peruvian Sol',
      flag: '🇵🇪',
      fallbackRateFromUsd: 3.76,
    ),
    CurrencySpec(
      code: 'BRL',
      symbol: 'R\$',
      name: 'Brazilian Real',
      flag: '🇧🇷',
      fallbackRateFromUsd: 5.80,
    ),
    CurrencySpec(
      code: 'UYU',
      symbol: '\$U',
      name: 'Uruguayan Peso',
      flag: '🇺🇾',
      fallbackRateFromUsd: 42.5,
    ),
    CurrencySpec(
      code: 'BOB',
      symbol: 'Bs',
      name: 'Bolivian Boliviano',
      flag: '🇧🇴',
      fallbackRateFromUsd: 6.91,
    ),
    CurrencySpec(
      code: 'PYG',
      symbol: '₲',
      name: 'Paraguayan Guaraní',
      flag: '🇵🇾',
      fallbackRateFromUsd: 7800.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'CRC',
      symbol: '₡',
      name: 'Costa Rican Colón',
      flag: '🇨🇷',
      fallbackRateFromUsd: 510.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'DOP',
      symbol: 'RD\$',
      name: 'Dominican Peso',
      flag: '🇩🇴',
      fallbackRateFromUsd: 60.2,
    ),
    CurrencySpec(
      code: 'GTQ',
      symbol: 'Q',
      name: 'Guatemalan Quetzal',
      flag: '🇬🇹',
      fallbackRateFromUsd: 7.72,
    ),
    CurrencySpec(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      flag: '🇬🇧',
      fallbackRateFromUsd: 0.79,
    ),
    CurrencySpec(
      code: 'CAD',
      symbol: 'CA\$',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      fallbackRateFromUsd: 1.40,
    ),
    CurrencySpec(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      fallbackRateFromUsd: 1.53,
    ),
    CurrencySpec(
      code: 'NZD',
      symbol: 'NZ\$',
      name: 'New Zealand Dollar',
      flag: '🇳🇿',
      fallbackRateFromUsd: 1.69,
    ),
    CurrencySpec(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      fallbackRateFromUsd: 154.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'KRW',
      symbol: '₩',
      name: 'South Korean Won',
      flag: '🇰🇷',
      fallbackRateFromUsd: 1395.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      flag: '🇨🇳',
      fallbackRateFromUsd: 7.24,
    ),
    CurrencySpec(
      code: 'HKD',
      symbol: 'HK\$',
      name: 'Hong Kong Dollar',
      flag: '🇭🇰',
      fallbackRateFromUsd: 7.78,
    ),
    CurrencySpec(
      code: 'TWD',
      symbol: 'NT\$',
      name: 'New Taiwan Dollar',
      flag: '🇹🇼',
      fallbackRateFromUsd: 32.5,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
      fallbackRateFromUsd: 1.34,
    ),
    CurrencySpec(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      flag: '🇨🇭',
      fallbackRateFromUsd: 0.88,
    ),
    CurrencySpec(
      code: 'SEK',
      symbol: 'kr',
      name: 'Swedish Krona',
      flag: '🇸🇪',
      fallbackRateFromUsd: 10.9,
    ),
    CurrencySpec(
      code: 'NOK',
      symbol: 'kr',
      name: 'Norwegian Krone',
      flag: '🇳🇴',
      fallbackRateFromUsd: 11.0,
    ),
    CurrencySpec(
      code: 'DKK',
      symbol: 'kr',
      name: 'Danish Krone',
      flag: '🇩🇰',
      fallbackRateFromUsd: 6.89,
    ),
    CurrencySpec(
      code: 'PLN',
      symbol: 'zł',
      name: 'Polish Zloty',
      flag: '🇵🇱',
      fallbackRateFromUsd: 4.08,
    ),
    CurrencySpec(
      code: 'CZK',
      symbol: 'Kč',
      name: 'Czech Koruna',
      flag: '🇨🇿',
      fallbackRateFromUsd: 23.8,
    ),
    CurrencySpec(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      flag: '🇮🇳',
      fallbackRateFromUsd: 84.4,
    ),
    CurrencySpec(
      code: 'PHP',
      symbol: '₱',
      name: 'Philippine Peso',
      flag: '🇵🇭',
      fallbackRateFromUsd: 58.6,
    ),
    CurrencySpec(
      code: 'THB',
      symbol: '฿',
      name: 'Thai Baht',
      flag: '🇹🇭',
      fallbackRateFromUsd: 34.7,
    ),
    CurrencySpec(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      flag: '🇲🇾',
      fallbackRateFromUsd: 4.46,
    ),
    CurrencySpec(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      flag: '🇮🇩',
      fallbackRateFromUsd: 15850.0,
      decimals: 0,
    ),
    CurrencySpec(
      code: 'ZAR',
      symbol: 'R',
      name: 'South African Rand',
      flag: '🇿🇦',
      fallbackRateFromUsd: 18.1,
    ),
    CurrencySpec(
      code: 'TRY',
      symbol: '₺',
      name: 'Turkish Lira',
      flag: '🇹🇷',
      fallbackRateFromUsd: 34.5,
    ),
    CurrencySpec(
      code: 'AED',
      symbol: 'د.إ',
      name: 'UAE Dirham',
      flag: '🇦🇪',
      fallbackRateFromUsd: 3.67,
    ),
    CurrencySpec(
      code: 'SAR',
      symbol: '﷼',
      name: 'Saudi Riyal',
      flag: '🇸🇦',
      fallbackRateFromUsd: 3.75,
    ),
    CurrencySpec(
      code: 'ILS',
      symbol: '₪',
      name: 'Israeli New Shekel',
      flag: '🇮🇱',
      fallbackRateFromUsd: 3.73,
    ),
  ];

  static const List<CountrySpec> countries = [
    CountrySpec(code: 'CL', name: 'Chile', flag: '🇨🇱', defaultCurrencyCode: 'CLP'),
    CountrySpec(code: 'US', name: 'United States', flag: '🇺🇸', defaultCurrencyCode: 'USD'),
    CountrySpec(code: 'ES', name: 'España', flag: '🇪🇸', defaultCurrencyCode: 'EUR'),
    CountrySpec(code: 'MX', name: 'México', flag: '🇲🇽', defaultCurrencyCode: 'MXN'),
    CountrySpec(code: 'AR', name: 'Argentina', flag: '🇦🇷', defaultCurrencyCode: 'ARS'),
    CountrySpec(code: 'CO', name: 'Colombia', flag: '🇨🇴', defaultCurrencyCode: 'COP'),
    CountrySpec(code: 'PE', name: 'Perú', flag: '🇵🇪', defaultCurrencyCode: 'PEN'),
    CountrySpec(code: 'BR', name: 'Brasil', flag: '🇧🇷', defaultCurrencyCode: 'BRL'),
    CountrySpec(code: 'UY', name: 'Uruguay', flag: '🇺🇾', defaultCurrencyCode: 'UYU'),
    CountrySpec(code: 'EC', name: 'Ecuador', flag: '🇪🇨', defaultCurrencyCode: 'USD'),
    CountrySpec(code: 'BO', name: 'Bolivia', flag: '🇧🇴', defaultCurrencyCode: 'BOB'),
    CountrySpec(code: 'PY', name: 'Paraguay', flag: '🇵🇾', defaultCurrencyCode: 'PYG'),
    CountrySpec(code: 'CR', name: 'Costa Rica', flag: '🇨🇷', defaultCurrencyCode: 'CRC'),
    CountrySpec(code: 'PA', name: 'Panamá', flag: '🇵🇦', defaultCurrencyCode: 'USD'),
    CountrySpec(code: 'DO', name: 'República Dominicana', flag: '🇩🇴', defaultCurrencyCode: 'DOP'),
    CountrySpec(code: 'GT', name: 'Guatemala', flag: '🇬🇹', defaultCurrencyCode: 'GTQ'),
    CountrySpec(code: 'CA', name: 'Canada', flag: '🇨🇦', defaultCurrencyCode: 'CAD'),
    CountrySpec(code: 'GB', name: 'United Kingdom', flag: '🇬🇧', defaultCurrencyCode: 'GBP'),
    CountrySpec(code: 'DE', name: 'Deutschland', flag: '🇩🇪', defaultCurrencyCode: 'EUR'),
    CountrySpec(code: 'FR', name: 'France', flag: '🇫🇷', defaultCurrencyCode: 'EUR'),
    CountrySpec(code: 'IT', name: 'Italia', flag: '🇮🇹', defaultCurrencyCode: 'EUR'),
    CountrySpec(code: 'PT', name: 'Portugal', flag: '🇵🇹', defaultCurrencyCode: 'EUR'),
    CountrySpec(code: 'CH', name: 'Schweiz / Suisse', flag: '🇨🇭', defaultCurrencyCode: 'CHF'),
    CountrySpec(code: 'SE', name: 'Sverige', flag: '🇸🇪', defaultCurrencyCode: 'SEK'),
    CountrySpec(code: 'NO', name: 'Norge', flag: '🇳🇴', defaultCurrencyCode: 'NOK'),
    CountrySpec(code: 'DK', name: 'Danmark', flag: '🇩🇰', defaultCurrencyCode: 'DKK'),
    CountrySpec(code: 'PL', name: 'Polska', flag: '🇵🇱', defaultCurrencyCode: 'PLN'),
    CountrySpec(code: 'JP', name: '日本 (Japan)', flag: '🇯🇵', defaultCurrencyCode: 'JPY'),
    CountrySpec(code: 'KR', name: '대한민국 (South Korea)', flag: '🇰🇷', defaultCurrencyCode: 'KRW'),
    CountrySpec(code: 'CN', name: '中国 (China)', flag: '🇨🇳', defaultCurrencyCode: 'CNY'),
    CountrySpec(code: 'TW', name: '台灣 (Taiwan)', flag: '🇹🇼', defaultCurrencyCode: 'TWD'),
    CountrySpec(code: 'SG', name: 'Singapore', flag: '🇸🇬', defaultCurrencyCode: 'SGD'),
    CountrySpec(code: 'AU', name: 'Australia', flag: '🇦🇺', defaultCurrencyCode: 'AUD'),
    CountrySpec(code: 'NZ', name: 'New Zealand', flag: '🇳🇿', defaultCurrencyCode: 'NZD'),
    CountrySpec(code: 'IN', name: 'India', flag: '🇮🇳', defaultCurrencyCode: 'INR'),
    CountrySpec(code: 'PH', name: 'Philippines', flag: '🇵🇭', defaultCurrencyCode: 'PHP'),
    CountrySpec(code: 'TH', name: 'Thailand', flag: '🇹🇭', defaultCurrencyCode: 'THB'),
    CountrySpec(code: 'ZA', name: 'South Africa', flag: '🇿🇦', defaultCurrencyCode: 'ZAR'),
    CountrySpec(code: 'AE', name: 'United Arab Emirates', flag: '🇦🇪', defaultCurrencyCode: 'AED'),
  ];

  static CurrencySpec currencyByCode(String code) {
    final normalized = code.toUpperCase();
    for (final spec in currencies) {
      if (spec.code == normalized) {
        return spec;
      }
    }
    return currencies.first;
  }

  static CountrySpec? countryByCode(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    final normalized = code.toUpperCase();
    for (final spec in countries) {
      if (spec.code == normalized) {
        return spec;
      }
    }
    return null;
  }

  static Map<String, double> get fallbackRates => {
    for (final spec in currencies) spec.code: spec.fallbackRateFromUsd,
  };
}
