import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/collections/collection_registry.dart';
import '../../../core/constants/api_constants.dart';
import 'catalog_mappers.dart';
import 'catalog_repository.dart';

class HttpCatalogRepository implements CatalogRepository {
  HttpCatalogRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<CatalogResult>> search({
    required CatalogProvider provider,
    required String query,
    required String languageCode,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const [];
    }
    return switch (provider) {
      CatalogProvider.scryfall => _searchMagic(normalizedQuery, languageCode),
      CatalogProvider.tcgdex => _searchPokemon(normalizedQuery, languageCode),
      CatalogProvider.ygoprodeck => _searchYugioh(
        normalizedQuery,
        languageCode,
      ),
    };
  }

  Future<List<CatalogResult>> _searchPokemon(
    String query,
    String languageCode,
  ) async {
    final localized = await _getTcgdex(query, languageCode);
    if (localized.isNotEmpty || languageCode == 'en') {
      return localized;
    }
    return _getTcgdex(query, 'en');
  }

  Future<List<CatalogResult>> _getTcgdex(String query, String language) async {
    final uri = Uri.https(
      ApiConstants.tcgdexHost,
      ApiConstants.tcgdexCardsPath(language),
      {'name': query},
    );
    final response = await _get(uri);
    if (response.statusCode == 404) {
      return const [];
    }
    final results = CatalogMappers.fromTcgdex(
      _decodeObject(response, expectsSingleValue: true),
    );
    return _enrichTcgdexPrices(results, language);
  }

  Future<List<CatalogResult>> _enrichTcgdexPrices(
    List<CatalogResult> results,
    String language,
  ) async {
    final limit = results.length < 24 ? results.length : 24;
    final enriched = List<CatalogResult>.from(results);
    await Future.wait(
      List.generate(limit, (index) async {
        final item = results[index];
        if (item.estimatedPrice != null) {
          return;
        }
        enriched[index] = await _fetchTcgdexDetail(item, language);
      }),
    );
    return enriched;
  }

  Future<CatalogResult> _fetchTcgdexDetail(
    CatalogResult item,
    String language,
  ) async {
    try {
      final detailUri = Uri.https(
        ApiConstants.tcgdexHost,
        '${ApiConstants.tcgdexCardsPath(language)}/${item.externalId}',
      );
      final detailResp = await _client
          .get(detailUri)
          .timeout(const Duration(seconds: 4));
      if (detailResp.statusCode != 200) {
        return item;
      }
      final decoded = jsonDecode(detailResp.body);
      if (decoded is! Map<String, dynamic>) {
        return item;
      }
      var price = CatalogMappers.extractTcgdexPrice(decoded['pricing']);
      if (price == null && decoded['variants_detailed'] is List) {
        final variants = decoded['variants_detailed'] as List;
        if (variants.isNotEmpty && variants.first is Map) {
          price = CatalogMappers.extractTcgdexPrice(
            (variants.first as Map)['pricing'],
          );
        }
      }
      final setName = (decoded['set'] as Map?)?['name']?.toString();
      final attacks = decoded['attacks'];
      final attackLines = <String>[];
      if (attacks is List) {
        for (final atk in attacks.whereType<Map>()) {
          final name = atk['name']?.toString() ?? '';
          final effect = atk['effect']?.toString() ?? '';
          final damage = atk['damage']?.toString() ?? '';
          final header = damage.isNotEmpty ? '$name ($damage)' : name;
          if (header.isNotEmpty) {
            attackLines.add(effect.isNotEmpty ? '$header: $effect' : header);
          }
        }
      }
      final updatedMeta = Map<String, dynamic>.from(item.metadata);
      if (setName != null && setName.isNotEmpty) {
        updatedMeta['expansion'] = setName;
      }
      if (decoded['rarity'] != null) {
        updatedMeta['rarity'] = decoded['rarity'].toString();
      }
      if (decoded['types'] is List) {
        updatedMeta['type'] = (decoded['types'] as List).join(', ');
      }
      if (attackLines.isNotEmpty) {
        updatedMeta['oracleText'] = attackLines.join('\n');
      }
      return CatalogResult(
        externalId: item.externalId,
        name: item.name,
        imageUrl: item.imageUrl,
        collectionCode: item.collectionCode,
        sourceType: item.sourceType,
        estimatedPrice: price ?? item.estimatedPrice,
        metadata: updatedMeta,
      );
    } catch (_) {
      return item;
    }
  }

  Future<List<CatalogResult>> _searchMagic(
    String query,
    String languageCode,
  ) async {
    final localized = await _getScryfall('name:$query lang:$languageCode');
    if (localized.isNotEmpty) {
      if (languageCode == 'en') {
        return localized;
      }
      return _enrichScryfallEnglishPrices(localized);
    }
    if (languageCode == 'en') {
      return localized;
    }
    return _getScryfall('name:$query lang:en');
  }

  Future<List<CatalogResult>> _enrichScryfallEnglishPrices(
    List<CatalogResult> results,
  ) async {
    final enriched = List<CatalogResult>.from(results);
    final missingIndices = <int>[];
    final identifiers = <Map<String, String>>[];

    for (var i = 0; i < results.length && identifiers.length < 75; i++) {
      final item = results[i];
      if (item.estimatedPrice != null) {
        continue;
      }
      final setCode = item.metadata['setCode']?.toString();
      final number = item.metadata['number']?.toString();
      if (setCode != null &&
          setCode.isNotEmpty &&
          number != null &&
          number.isNotEmpty) {
        missingIndices.add(i);
        identifiers.add({'set': setCode, 'collector_number': number});
      }
    }

    if (identifiers.isEmpty) {
      return enriched;
    }

    try {
      final uri = Uri.https(ApiConstants.scryfallHost, '/cards/collection');
      final resp = await _client
          .post(
            uri,
            headers: const {
              'User-Agent': 'AuraDeck/1.0',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'identifiers': identifiers}),
          )
          .timeout(const Duration(seconds: 6));

      if (resp.statusCode != 200) {
        return enriched;
      }
      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
        return enriched;
      }

      final priceByKey = <String, double>{};
      for (final raw in (decoded['data'] as List).whereType<Map>()) {
        final setCode = raw['set']?.toString();
        final number = raw['collector_number']?.toString();
        if (setCode == null || number == null) {
          continue;
        }
        final prices = raw['prices'] as Map?;
        final usd = double.tryParse(prices?['usd']?.toString() ?? '');
        final usdFoil = double.tryParse(prices?['usd_foil']?.toString() ?? '');
        final usdEtched = double.tryParse(
          prices?['usd_etched']?.toString() ?? '',
        );
        final eur = double.tryParse(prices?['eur']?.toString() ?? '');
        final resolved =
            usd ?? usdFoil ?? usdEtched ?? (eur != null ? eur * 1.08 : null);
        if (resolved != null) {
          priceByKey['$setCode/$number'] = resolved;
        }
      }

      for (final idx in missingIndices) {
        final item = enriched[idx];
        final key =
            '${item.metadata['setCode']?.toString()}/${item.metadata['number']?.toString()}';
        final resolvedPrice = priceByKey[key];
        if (resolvedPrice != null) {
          enriched[idx] = CatalogResult(
            externalId: item.externalId,
            name: item.name,
            imageUrl: item.imageUrl,
            collectionCode: item.collectionCode,
            sourceType: item.sourceType,
            estimatedPrice: resolvedPrice,
            metadata: item.metadata,
          );
        }
      }
    } catch (_) {
      // Keep localized results if batch price enrichment fails.
    }
    return enriched;
  }

  Future<List<CatalogResult>> _getScryfall(String query) async {
    final uri = Uri.https(
      ApiConstants.scryfallHost,
      ApiConstants.scryfallSearchPath,
      {'q': query},
    );
    final response = await _get(uri);
    if (response.statusCode == 404) {
      return const [];
    }
    return CatalogMappers.fromScryfall(_decodeObject(response));
  }

  Future<List<CatalogResult>> _searchYugioh(
    String query,
    String languageCode,
  ) async {
    if (languageCode == 'pt') {
      final localized = await _getYgoprodeck(query, language: 'pt');
      if (localized.isNotEmpty) {
        return localized;
      }
    }
    return _getYgoprodeck(query);
  }

  Future<List<CatalogResult>> _getYgoprodeck(
    String query, {
    String? language,
  }) async {
    final params = <String, String>{'fname': query};
    if (language != null) {
      params['language'] = language;
    }
    final uri = Uri.https(
      ApiConstants.ygoprodeckHost,
      ApiConstants.ygoprodeckCardInfoPath,
      params,
    );
    final response = await _get(uri);
    // YGOPRODeck returns 400 when no card matches the query.
    if (response.statusCode == 400 || response.statusCode == 404) {
      return const [];
    }
    return CatalogMappers.fromYgoprodeck(_decodeObject(response));
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': ApiConstants.scryfallUserAgent,
            },
          )
          .timeout(ApiConstants.apiTimeout);
      if (response.statusCode == 429) {
        throw const CatalogRepositoryException(CatalogErrorType.rateLimited);
      }
      if (response.statusCode >= 500) {
        throw const CatalogRepositoryException(CatalogErrorType.unavailable);
      }
      return response;
    } on http.ClientException {
      throw const CatalogRepositoryException(CatalogErrorType.offline);
    } on TimeoutException {
      throw const CatalogRepositoryException(CatalogErrorType.offline);
    }
  }

  Map<String, dynamic> _decodeObject(
    http.Response response, {
    bool expectsSingleValue = false,
  }) {
    if (response.statusCode >= 400 && response.statusCode != 404) {
      throw const CatalogRepositoryException(CatalogErrorType.unavailable);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (expectsSingleValue && decoded is List) {
        return {'cards': decoded};
      }
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      throw const CatalogRepositoryException(CatalogErrorType.unavailable);
    }
    return const {};
  }
}
