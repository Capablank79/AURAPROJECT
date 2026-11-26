import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'currency_registry.dart';

class ExchangeRateService {
  ExchangeRateService({
    required SharedPreferences preferences,
    http.Client? client,
  }) : _preferences = preferences,
       _client = client ?? http.Client();

  static const _cacheKey = 'exchange_rates_usd_cache';
  static const _cacheTimestampKey = 'exchange_rates_usd_ts';
  static const _cacheTtl = Duration(hours: 12);
  static final _endpoint = Uri.parse('https://open.er-api.com/v6/latest/USD');

  final SharedPreferences _preferences;
  final http.Client _client;

  Future<Map<String, double>> getRates() async {
    final fallback = CurrencyRegistry.fallbackRates;
    final cached = _readCachedRates();
    if (cached != null && _isCacheFresh()) {
      return {...fallback, ...cached};
    }

    try {
      final response = await _client
          .get(_endpoint)
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final rawRates = decoded['rates'];
        if (rawRates is Map) {
          final parsed = <String, double>{};
          for (final entry in rawRates.entries) {
            final value = entry.value;
            if (value is num && value > 0) {
              parsed[entry.key.toString().toUpperCase()] = value.toDouble();
            }
          }
          if (parsed.isNotEmpty) {
            await _saveCache(parsed);
            return {...fallback, ...parsed};
          }
        }
      }
    } catch (_) {
      // Offline or rate-limited: fall back to cache or built-in rates.
    }

    if (cached != null) {
      return {...fallback, ...cached};
    }
    return fallback;
  }

  bool _isCacheFresh() {
    final ts = _preferences.getInt(_cacheTimestampKey);
    if (ts == null) {
      return false;
    }
    final savedAt = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
    return DateTime.now().toUtc().difference(savedAt) < _cacheTtl;
  }

  Map<String, double>? _readCachedRates() {
    final raw = _preferences.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          if (entry.value is num) entry.key: (entry.value as num).toDouble(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(Map<String, double> rates) async {
    await _preferences.setString(_cacheKey, jsonEncode(rates));
    await _preferences.setInt(
      _cacheTimestampKey,
      DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }
}
