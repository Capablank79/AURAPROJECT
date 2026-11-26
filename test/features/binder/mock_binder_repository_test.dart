import 'package:aura_deck/core/constants/app_constants.dart';
import 'package:aura_deck/core/models/binder_model.dart';
import 'package:aura_deck/core/models/item_model.dart';
import 'package:aura_deck/core/models/profile_model.dart';
import 'package:aura_deck/features/binder/data/mock_binder_repository.dart';
import 'package:aura_deck/features/binder/data/repositories/binder_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const userId = '00000000-0000-0000-0000-000000000001';
  final profile = ProfileModel(
    id: userId,
    username: 'tester',
    preferredLanguage: 'es',
    isPro: false,
    isAdmin: false,
    extraBinderCredits: 0,
    createdAt: DateTime.utc(2026),
  );

  group('MockBinderRepository capacity and anti-mixing rules', () {
    test('starts without imposing a default collection', () async {
      final repository = MockBinderRepository(profile: profile);
      expect(await repository.getBinders(), isEmpty);
    });

    test('creates the first free 360-slot binder', () async {
      final repository = MockBinderRepository(profile: profile);

      final binder = await repository.createBinder(
        title: 'First',
        family: 'cards',
        collectionCode: 'magic',
        isPublic: false,
      );

      expect(binder.isFreeTier, isTrue);
      expect(binder.collectionCode, 'magic');
      expect(binder.maxSlots, AppConstants.standardBinderSlots);
    });

    test('blocks a second binder without Pro or credits', () async {
      final repository = MockBinderRepository(
        profile: profile,
        binders: [_binder(userId)],
      );

      expect(
        () => repository.createBinder(
          title: 'Second',
          family: 'cards',
          collectionCode: 'pokemon',
          isPublic: false,
        ),
        throwsA(isA<BinderLimitException>()),
      );
    });

    test(
      'rejects mixing Pokemon cards inside a Magic binder and vice versa',
      () async {
        final magicBinder = _binder(userId, code: 'magic');
        final repository = MockBinderRepository(
          profile: profile,
          binders: [magicBinder],
        );

        final pokemonItem = _item(
          magicBinder,
          0,
          collectionCode: 'pokemon',
          sourceType: 'api_tcgdex',
        );

        expect(
          () => repository.addItem(pokemonItem),
          throwsA(isA<CollectionMismatchException>()),
        );
      },
    );

    test(
      'requires customCollectionName when collectionCode is other_card',
      () async {
        final repository = MockBinderRepository(profile: profile);

        expect(
          () => repository.createBinder(
            title: 'Custom',
            family: 'cards',
            collectionCode: 'other_card',
            isPublic: false,
          ),
          throwsA(isA<InvalidCustomCollectionException>()),
        );
      },
    );

    test('enforces unique position_index', () async {
      final binder = _binder(userId);
      final repository = MockBinderRepository(
        profile: profile,
        binders: [binder],
        items: [_item(binder, 0)],
      );

      expect(
        () => repository.addItem(_item(binder, 0, id: 'second')),
        throwsA(isA<ItemPositionException>()),
      );
    });

    test('enforces max_slots', () async {
      final binder = _binder(userId).copyWith(maxSlots: 2);
      final repository = MockBinderRepository(
        profile: profile,
        binders: [binder],
      );

      expect(
        () => repository.addItem(_item(binder, 2)),
        throwsA(isA<BinderCapacityException>()),
      );
    });

    test(
      'consumes 1 extra_binder_credit when creating a second binder',
      () async {
        final creditedProfile = profile.copyWith(extraBinderCredits: 1);
        final repository = MockBinderRepository(
          profile: creditedProfile,
          binders: [_binder(userId)],
        );

        final second = await repository.createBinder(
          title: 'Second',
          family: 'cards',
          collectionCode: 'pokemon',
          isPublic: true,
        );

        expect(second.isFreeTier, isFalse);
        final updatedProfile = await repository.getActiveProfile();
        expect(updatedProfile.extraBinderCredits, 0);
      },
    );

    test('completeBinder releases unused slots to Space Bank and deleteBinder returns all slots', () async {
      final repository = MockBinderRepository();
      final binder = await repository.createBinder(
        title: 'Pokémon 151',
        family: 'cards',
        collectionCode: 'pokemon',
        isPublic: false,
      );
      await repository.addItem(_item(binder, 0));
      await repository.addItem(_item(binder, 1));

      final completed = await repository.completeBinder(binder.id);
      expect(completed.isCompleted, isTrue);
      expect(completed.maxSlots, 2);

      var profile = await repository.getActiveProfile();
      expect(profile.availableSlots, 358);

      final resized = await repository.resizeBinder(
        binderId: binder.id,
        newMaxSlots: 11,
      );
      expect(resized.maxSlots, 11);
      profile = await repository.getActiveProfile();
      expect(profile.availableSlots, 349);

      await repository.deleteBinder(binder.id);
      profile = await repository.getActiveProfile();
      expect(profile.availableSlots, 360);
    });
  });
}

BinderModel _binder(String userId, {String code = 'magic'}) => BinderModel(
  id: 'binder-1',
  userId: userId,
  title: 'Collection',
  family: 'cards',
  collectionCode: code,
  gridFormat: '3x3',
  maxSlots: 360,
  isFreeTier: true,
  theme: 'obsidian_gold',
  isPublic: false,
  createdAt: DateTime.utc(2026),
);

ItemModel _item(
  BinderModel binder,
  int position, {
  String id = 'item-1',
  String? collectionCode,
  String sourceType = 'user_upload',
}) => ItemModel(
  id: id,
  binderId: binder.id,
  userId: binder.userId,
  collectionCode: collectionCode ?? binder.collectionCode,
  sourceType: sourceType,
  name: 'Collectible',
  imageUrl: 'mock://item.webp',
  isFoil: false,
  condition: 'NM',
  positionIndex: position,
  metadata: const {},
  createdAt: DateTime.utc(2026),
);
