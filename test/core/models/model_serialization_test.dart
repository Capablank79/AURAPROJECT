import 'package:aura_deck/core/collections/collection_registry.dart';
import 'package:aura_deck/core/models/binder_model.dart';
import 'package:aura_deck/core/models/item_model.dart';
import 'package:aura_deck/core/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProfileModel preserves SQL column names and nullable values', () {
    final profile = ProfileModel.fromJson({
      'id': 'profile-id',
      'username': 'collector',
      'display_name': null,
      'avatar_url': null,
      'preferred_language': 'pt',
      'is_pro': true,
      'is_admin': false,
      'extra_binder_credits': 2,
      'revenuecat_app_user_id': null,
      'created_at': '2026-11-25T03:00:00Z',
    });

    expect(profile.toJson(), {
      'id': 'profile-id',
      'username': 'collector',
      'display_name': null,
      'avatar_url': null,
      'preferred_language': 'pt',
      'is_pro': true,
      'is_admin': false,
      'extra_binder_credits': 2,
      'revenuecat_app_user_id': null,
      'created_at': '2026-11-25T03:00:00.000Z',
    });
  });

  test('BinderModel round-trips family, collection_code, and custom name', () {
    final json = {
      'id': 'binder-id',
      'user_id': 'profile-id',
      'title': 'Collection',
      'family': 'cards',
      'collection_code': 'other_card',
      'custom_collection_name': 'Mitos y Leyendas',
      'category': 'custom',
      'grid_format': '3x3',
      'max_slots': 360,
      'is_free_tier': true,
      'theme': 'obsidian_gold',
      'is_public': true,
      'created_at': '2026-11-25T03:00:00Z',
    };

    expect(BinderModel.fromJson(json).toJson(), {
      ...json,
      'is_completed': false,
      'created_at': '2026-11-25T03:00:00.000Z',
    });
  });

  test('ItemModel round-trips collection_code, JSONB metadata and nulls', () {
    final item = ItemModel.fromJson({
      'id': 'item-id',
      'binder_id': 'binder-id',
      'user_id': 'profile-id',
      'collection_code': 'pokemon',
      'source_type': 'api_tcgdex',
      'external_id': null,
      'name': 'Mew',
      'image_url': 'https://example.test/mew.webp',
      'is_foil': true,
      'condition': 'NM',
      'estimated_price': null,
      'position_index': 4,
      'metadata': {'rarity': 'Special', 'number': 151},
      'notes': null,
      'created_at': '2026-11-25T03:00:00Z',
    });

    expect(item.collectionCode, 'pokemon');
    expect(item.metadata, {'rarity': 'Special', 'number': 151});
    expect(item.toJson(), containsPair('collection_code', 'pokemon'));
    expect(item.toJson(), containsPair('estimated_price', null));
    expect(item.toJson(), containsPair('external_id', null));
    expect(item.toJson(), containsPair('metadata', item.metadata));
  });

  test(
    'CollectionRegistry orders Magic first, Pokemon second, and gates APIs',
    () {
      final cards = CollectionRegistry.cardCollections;
      expect(cards.first.code, 'magic');
      expect(cards[1].code, 'pokemon');
      expect(cards[2].code, 'yugioh');

      expect(CollectionRegistry.byCode('magic').supportsApiSearch, isTrue);
      expect(CollectionRegistry.byCode('pokemon').supportsApiSearch, isTrue);
      expect(CollectionRegistry.byCode('yugioh').supportsApiSearch, isTrue);
      expect(CollectionRegistry.byCode('naruto').supportsApiSearch, isFalse);
      expect(CollectionRegistry.byCode('naruto').supportsCardScanner, isFalse);
      expect(
        CollectionRegistry.byCode('other_card').requiresCustomName,
        isTrue,
      );
    },
  );
}
