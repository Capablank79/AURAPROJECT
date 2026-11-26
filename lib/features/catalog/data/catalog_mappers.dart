import 'catalog_repository.dart';

abstract final class CatalogMappers {
  static List<CatalogResult> fromTcgdex(Map<String, dynamic> json) {
    final cards = json['cards'];
    if (cards is! List) {
      return const [];
    }
    return cards
        .whereType<Map>()
        .map((raw) {
          final card = Map<String, dynamic>.from(raw);
          final image = card['image'];
          return CatalogResult(
            externalId: card['id']?.toString() ?? '',
            name: card['name']?.toString() ?? '',
            imageUrl: image is String ? '$image/high.webp' : '',
            collectionCode: 'pokemon',
            sourceType: 'api_tcgdex',
            estimatedPrice: _extractTcgdexPrice(card['pricing']),
            metadata: {
              'expansion':
                  (card['set'] as Map?)?['name']?.toString() ?? 'Unknown',
              'number': card['localId']?.toString(),
              'rarity': card['rarity']?.toString(),
              'type': (card['types'] as List?)?.join(', '),
              'artist': card['illustrator']?.toString(),
            },
          );
        })
        .where((card) => card.externalId.isNotEmpty && card.name.isNotEmpty)
        .toList();
  }

  static List<CatalogResult> fromScryfall(Map<String, dynamic> json) {
    final cards = json['data'];
    if (cards is! List) {
      return const [];
    }
    return cards
        .whereType<Map>()
        .map((raw) {
          final card = Map<String, dynamic>.from(raw);
          final imageUris = card['image_uris'] as Map?;
          final cardFaces = card['card_faces'] as List?;
          final fallbackFaceUris =
              (cardFaces != null &&
                  cardFaces.isNotEmpty &&
                  cardFaces.first is Map)
              ? (cardFaces.first as Map)['image_uris'] as Map?
              : null;
          final prices = card['prices'] as Map?;
          final usd = double.tryParse(prices?['usd']?.toString() ?? '');
          final usdFoil = double.tryParse(prices?['usd_foil']?.toString() ?? '');
          final usdEtched = double.tryParse(
            prices?['usd_etched']?.toString() ?? '',
          );
          final eur = double.tryParse(prices?['eur']?.toString() ?? '');
          final resolvedPrice =
              usd ?? usdFoil ?? usdEtched ?? (eur != null ? eur * 1.08 : null);

          return CatalogResult(
            externalId: card['id']?.toString() ?? '',
            name: card['name']?.toString() ?? '',
            imageUrl:
                imageUris?['normal']?.toString() ??
                imageUris?['small']?.toString() ??
                fallbackFaceUris?['normal']?.toString() ??
                '',
            collectionCode: 'magic',
            sourceType: 'api_scryfall',
            estimatedPrice: resolvedPrice,
            metadata: {
              'expansion': card['set_name']?.toString(),
              'setCode': card['set']?.toString(),
              'number': card['collector_number']?.toString(),
              'rarity': card['rarity']?.toString(),
              'type': card['type_line']?.toString(),
              'artist': card['artist']?.toString(),
              'oracleText':
                  card['oracle_text']?.toString() ??
                  card['printed_text']?.toString() ??
                  (cardFaces != null &&
                          cardFaces.isNotEmpty &&
                          cardFaces.first is Map
                      ? (cardFaces.first as Map)['oracle_text']?.toString()
                      : null),
              'usdFoil': ?usdFoil,
            },
          );
        })
        .where((card) => card.externalId.isNotEmpty && card.name.isNotEmpty)
        .toList();
  }

  static List<CatalogResult> fromYgoprodeck(Map<String, dynamic> json) {
    final cards = json['data'];
    if (cards is! List) {
      return const [];
    }
    return cards
        .whereType<Map>()
        .map((raw) {
          final card = Map<String, dynamic>.from(raw);
          final images = card['card_images'] as List?;
          final firstImage =
              (images != null && images.isNotEmpty && images.first is Map)
              ? images.first as Map
              : null;
          final sets = card['card_sets'] as List?;
          final firstSet =
              (sets != null && sets.isNotEmpty && sets.first is Map)
              ? sets.first as Map
              : null;
          final prices = card['card_prices'] as List?;
          final firstPrice =
              (prices != null && prices.isNotEmpty && prices.first is Map)
              ? prices.first as Map
              : null;
          final rawUsd =
              firstPrice?['tcgplayer_price']?.toString() ??
              firstPrice?['cardmarket_price']?.toString() ??
              '';
          final parsedPrice = double.tryParse(rawUsd);

          return CatalogResult(
            externalId: card['id']?.toString() ?? '',
            name: card['name']?.toString() ?? '',
            imageUrl:
                firstImage?['image_url']?.toString() ??
                firstImage?['image_url_small']?.toString() ??
                '',
            collectionCode: 'yugioh',
            sourceType: 'api_ygoprodeck',
            estimatedPrice: parsedPrice != null && parsedPrice > 0
                ? parsedPrice
                : null,
            metadata: {
              'expansion': firstSet?['set_name']?.toString(),
              'number': firstSet?['set_code']?.toString(),
              'rarity': firstSet?['set_rarity']?.toString(),
              'type': card['type']?.toString(),
              'oracleText': card['desc']?.toString(),
            },
          );
        })
        .where((card) => card.externalId.isNotEmpty && card.name.isNotEmpty)
        .toList();
  }

  static double? extractTcgdexPrice(dynamic pricing) =>
      _extractTcgdexPrice(pricing);

  static double? _extractTcgdexPrice(dynamic pricing) {
    if (pricing is! Map) {
      return null;
    }
    final tcgplayer = pricing['tcgplayer'];
    if (tcgplayer is Map) {
      for (final variant in ['normal', 'holofoil', 'reverse-holofoil']) {
        final node = tcgplayer[variant];
        if (node is Map) {
          final price =
              (node['marketPrice'] as num?)?.toDouble() ??
              (node['midPrice'] as num?)?.toDouble() ??
              (node['lowPrice'] as num?)?.toDouble();
          if (price != null && price > 0) {
            return price;
          }
        }
      }
    }
    final cardmarket = pricing['cardmarket'];
    if (cardmarket is Map) {
      final eur =
          (cardmarket['trend'] as num?)?.toDouble() ??
          (cardmarket['avg'] as num?)?.toDouble() ??
          (cardmarket['low'] as num?)?.toDouble();
      if (eur != null && eur > 0) {
        return double.parse((eur * 1.08).toStringAsFixed(2));
      }
    }
    return null;
  }
}
