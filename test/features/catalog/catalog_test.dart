import 'package:aura_deck/core/utils/image_compressor.dart';
import 'package:aura_deck/features/catalog/data/catalog_mappers.dart';
import 'package:aura_deck/features/catalog/data/debounced_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps TCGdex responses into Pokemon catalog contracts', () {
    final results = CatalogMappers.fromTcgdex({
      'cards': [
        {
          'id': 'sv3pt5-151',
          'name': 'Mew ex',
          'image': 'https://assets.test/mew',
          'set': {'name': '151'},
          'localId': '151',
          'rarity': 'Special',
          'types': ['Psychic'],
          'illustrator': 'Artist',
        },
      ],
    });

    expect(results, hasLength(1));
    expect(results.single.externalId, 'sv3pt5-151');
    expect(results.single.collectionCode, 'pokemon');
    expect(results.single.sourceType, 'api_tcgdex');
    expect(results.single.imageUrl, endsWith('/high.webp'));
  });

  test('maps Scryfall responses into Magic catalog contracts', () {
    final results = CatalogMappers.fromScryfall({
      'data': [
        {
          'id': 'card-id',
          'name': 'Sol Ring',
          'image_uris': {'normal': 'https://cards.test/sol-ring.jpg'},
          'prices': {'usd': '9.50'},
          'set_name': 'Commander',
          'collector_number': '1',
          'rarity': 'uncommon',
          'type_line': 'Artifact',
          'artist': 'Mark Tedin',
        },
      ],
    });

    expect(results.single.collectionCode, 'magic');
    expect(results.single.sourceType, 'api_scryfall');
    expect(results.single.estimatedPrice, 9.5);
    expect(results.single.imageUrl, 'https://cards.test/sol-ring.jpg');
  });

  test('maps YGOPRODeck responses into Yu-Gi-Oh! catalog contracts', () {
    final results = CatalogMappers.fromYgoprodeck({
      'data': [
        {
          'id': 89631139,
          'name': 'Blue-Eyes White Dragon',
          'type': 'Normal Monster',
          'desc': 'This legendary dragon is a powerful engine of destruction.',
          'card_sets': [
            {
              'set_name': 'Legend of Blue Eyes White Dragon',
              'set_code': 'LOB-001',
              'set_rarity': 'Ultra Rare',
            },
          ],
          'card_images': [
            {
              'image_url':
                  'https://images.ygoprodeck.com/images/cards/89631139.jpg',
            },
          ],
          'card_prices': [
            {'tcgplayer_price': '18.25'},
          ],
        },
      ],
    });

    expect(results, hasLength(1));
    expect(results.single.externalId, '89631139');
    expect(results.single.collectionCode, 'yugioh');
    expect(results.single.sourceType, 'api_ygoprodeck');
    expect(results.single.estimatedPrice, 18.25);
    expect(
      results.single.metadata['expansion'],
      'Legend of Blue Eyes White Dragon',
    );
  });

  test('debounces and cancels obsolete searches', () async {
    var executions = 0;
    final search = DebouncedSearch<int>(
      delay: const Duration(milliseconds: 30),
    );

    final obsolete = search.run(() async {
      executions++;
      return 1;
    });
    final latest = search.run(() async {
      executions++;
      return 2;
    });

    expect(await obsolete, isNull);
    expect(await latest, 2);
    expect(executions, 1);
  });

  test('CatalogResult.toItem preserves condition and isFoil', () {
    final results = CatalogMappers.fromScryfall({
      'data': [
        {
          'id': 'card-id',
          'name': 'Black Lotus',
          'image_uris': {'normal': 'https://cards.test/lotus.jpg'},
        },
      ],
    });

    final item = results.single.toItem(
      binderId: 'binder-1',
      userId: 'user-1',
      positionIndex: 3,
      condition: 'SEALED',
      isFoil: true,
    );

    expect(item.condition, 'SEALED');
    expect(item.isFoil, isTrue);
    expect(item.positionIndex, 3);
  });

  test('CompressedImageResult formats KB and MB sizes cleanly', () {
    expect(CompressedImageResult.formatSize(45000), '44 KB');
    expect(CompressedImageResult.formatSize(2 * 1024 * 1024), '2.0 MB');
  });
}
