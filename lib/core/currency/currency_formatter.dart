import 'package:intl/intl.dart';

import 'currency_registry.dart';

abstract final class CurrencyFormatter {
  static double convertFromUsd(
    double usdAmount,
    String currencyCode,
    Map<String, double> rates,
  ) {
    final spec = CurrencyRegistry.currencyByCode(currencyCode);
    final rate = rates[spec.code] ?? spec.fallbackRateFromUsd;
    return usdAmount * rate;
  }

  static String formatFromUsd(
    double usdAmount, {
    required String currencyCode,
    required Map<String, double> rates,
    bool includeCode = true,
  }) {
    final spec = CurrencyRegistry.currencyByCode(currencyCode);
    final converted = convertFromUsd(usdAmount, spec.code, rates);
    final formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: spec.decimals,
    );
    final formattedNumber = formatter.format(converted);
    if (includeCode && spec.symbol == '\$') {
      return '${spec.symbol}$formattedNumber ${spec.code}';
    }
    return '${spec.symbol}$formattedNumber';
  }
}
