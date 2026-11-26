import 'package:aura_deck/core/currency/currency_formatter.dart';
import 'package:aura_deck/core/currency/currency_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('country lookup maps Chile to CLP and US to USD', () {
    final cl = CurrencyRegistry.countryByCode('CL');
    final us = CurrencyRegistry.countryByCode('US');
    expect(cl?.defaultCurrencyCode, 'CLP');
    expect(cl?.flag, '🇨🇱');
    expect(us?.defaultCurrencyCode, 'USD');
    expect(us?.flag, '🇺🇸');
  });

  test('CurrencyFormatter converts USD to CLP without decimals and EUR with 2 decimals', () {
    final rates = {'USD': 1.0, 'CLP': 950.0, 'EUR': 0.90};

    final usd = CurrencyFormatter.formatFromUsd(
      10.0,
      currencyCode: 'USD',
      rates: rates,
    );
    final clp = CurrencyFormatter.formatFromUsd(
      10.0,
      currencyCode: 'CLP',
      rates: rates,
    );
    final eur = CurrencyFormatter.formatFromUsd(
      10.0,
      currencyCode: 'EUR',
      rates: rates,
    );

    expect(usd, '\$10.00 USD');
    expect(clp, '\$9,500 CLP');
    expect(eur, '€9.00');
  });
}
