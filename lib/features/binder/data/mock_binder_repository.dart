import '../../../core/collections/collection_registry.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/models/profile_model.dart';
import 'repositories/binder_repository.dart';

class MockBinderRepository implements BinderRepository {
  MockBinderRepository({
    ProfileModel? profile,
    List<BinderModel>? binders,
    List<ItemModel>? items,
  }) : _profile = profile ?? _defaultProfile,
       _binders = List.of(binders ?? const []),
       _items = List.of(items ?? const []);

  MockBinderRepository.demo()
    : this(
        profile: _defaultProfile.copyWithDemoPro(),
        binders: _defaultBinders,
        items: _defaultItems,
      );

  ProfileModel _profile;
  final List<BinderModel> _binders;
  final List<ItemModel> _items;
  final List<TrashedItemRecord> _trashedItems = [];
  int _nextId = 100;

  @override
  Future<ProfileModel> getActiveProfile() async => _profile;

  @override
  Future<ProfileModel> updateProfileIdentity({
    String? displayName,
    String? tradeContact,
  }) async {
    final trimmedName = displayName?.trim();
    final trimmedContact = tradeContact?.trim();
    _profile = _profile.copyWith(
      displayName: trimmedName != null && trimmedName.isNotEmpty
          ? trimmedName
          : _profile.displayName,
      tradeContact: trimmedContact != null && trimmedContact.isNotEmpty
          ? trimmedContact
          : null,
      clearTradeContact: trimmedContact != null && trimmedContact.isEmpty,
    );
    return _profile;
  }

  @override
  Future<ProfileModel> updateProfileEntitlements({
    bool? isPro,
    bool? isAdmin,
    int? extraBinderCredits,
    int? availableSlots,
  }) async {
    _profile = _profile.copyWith(
      isPro: isPro ?? _profile.isPro,
      isAdmin: isAdmin ?? _profile.isAdmin,
      extraBinderCredits: extraBinderCredits ?? _profile.extraBinderCredits,
      availableSlots: availableSlots ?? _profile.availableSlots,
    );
    return _profile;
  }

  @override
  Future<List<BinderModel>> getBinders() async => List.unmodifiable(_binders);

  @override
  Future<BinderModel?> getBinder(String binderId) async {
    for (final binder in _binders) {
      if (binder.id == binderId) {
        return binder;
      }
    }
    return null;
  }

  @override
  Future<List<ItemModel>> getItems(String binderId) async {
    final items = _items.where((item) => item.binderId == binderId).toList()
      ..sort((a, b) => a.positionIndex.compareTo(b.positionIndex));
    return List.unmodifiable(items);
  }

  @override
  Future<BinderModel> createBinder({
    required String title,
    required String family,
    required String collectionCode,
    String? customCollectionName,
    required bool isPublic,
    int? maxSlots,
  }) async {
    final spec = CollectionRegistry.byCode(collectionCode);
    final normalizedCustom = customCollectionName?.trim();
    if (spec.requiresCustomName &&
        (normalizedCustom == null || normalizedCustom.isEmpty)) {
      throw const InvalidCustomCollectionException();
    }

    final targetSlots = (maxSlots ?? AppConstants.standardBinderSlots).clamp(
      AppConstants.sheetSlots,
      AppConstants.maxBinderSlots,
    );

    final isFirst = _binders.isEmpty;
    if (isFirst) {
      if (!_profile.isPro &&
          !_profile.isAdmin &&
          targetSlots < AppConstants.standardBinderSlots) {
        _profile = _profile.copyWith(
          availableSlots:
              _profile.availableSlots +
              (AppConstants.standardBinderSlots - targetSlots),
        );
      } else if (!_profile.isPro &&
          !_profile.isAdmin &&
          targetSlots > AppConstants.standardBinderSlots) {
        final extraNeeded = targetSlots - AppConstants.standardBinderSlots;
        if (_profile.availableSlots < extraNeeded) {
          throw const BinderCapacityException();
        }
        _profile = _profile.copyWith(
          availableSlots: _profile.availableSlots - extraNeeded,
        );
      }
    } else if (!_profile.isPro && !_profile.isAdmin) {
      if (_profile.extraBinderCredits > 0) {
        _profile = _profile.copyWith(
          extraBinderCredits: _profile.extraBinderCredits - 1,
        );
      } else if (_profile.availableSlots >= targetSlots && targetSlots > 0) {
        _profile = _profile.copyWith(
          availableSlots: _profile.availableSlots - targetSlots,
        );
      } else {
        throw const BinderLimitException();
      }
    }

    final binder = BinderModel(
      id: _newId('binder'),
      userId: _profile.id,
      title: title.trim(),
      family: family,
      collectionCode: collectionCode,
      customCollectionName: normalizedCustom == null || normalizedCustom.isEmpty
          ? null
          : normalizedCustom,
      gridFormat: '3x3',
      maxSlots: targetSlots,
      isFreeTier: isFirst,
      theme: 'obsidian_gold',
      isPublic: isPublic,
      createdAt: DateTime.now().toUtc(),
    );
    _binders.add(binder);
    return binder;
  }

  @override
  Future<BinderModel> updateBinder({
    required String binderId,
    String? title,
    String? gridFormat,
    bool? isPublic,
  }) async {
    final index = _binders.indexWhere((b) => b.id == binderId);
    if (index == -1) {
      throw const BinderRepositoryException('Binder not found.');
    }
    final current = _binders[index];
    final updated = current.copyWith(
      title: title != null && title.trim().isNotEmpty ? title.trim() : null,
      gridFormat: gridFormat,
      isPublic: isPublic,
    );
    _binders[index] = updated;
    return updated;
  }

  @override
  Future<BinderModel> resizeBinder({
    required String binderId,
    required int newMaxSlots,
  }) async {
    final index = _binders.indexWhere((b) => b.id == binderId);
    if (index == -1) {
      throw const BinderRepositoryException('Binder not found.');
    }
    final current = _binders[index];
    final occupied = _items.where((item) => item.binderId == binderId).length;
    if (newMaxSlots < occupied ||
        newMaxSlots < 0 ||
        newMaxSlots > AppConstants.maxBinderSlots) {
      throw const BinderCapacityException();
    }

    final delta = newMaxSlots - current.maxSlots;
    if (delta > 0 && !_profile.isPro && !_profile.isAdmin) {
      if (_profile.availableSlots < delta) {
        throw const BinderCapacityException();
      }
      _profile = _profile.copyWith(
        availableSlots: _profile.availableSlots - delta,
      );
    } else if (delta < 0) {
      _profile = _profile.copyWith(
        availableSlots: _profile.availableSlots + (-delta),
      );
    }

    final updated = current.copyWith(
      maxSlots: newMaxSlots,
      isCompleted: delta > 0 ? false : current.isCompleted,
    );
    _binders[index] = updated;
    return updated;
  }

  @override
  Future<BinderModel> completeBinder(String binderId) async {
    final index = _binders.indexWhere((b) => b.id == binderId);
    if (index == -1) {
      throw const BinderRepositoryException('Binder not found.');
    }
    final current = _binders[index];
    final occupied = _items.where((item) => item.binderId == binderId).length;
    final released = current.maxSlots - occupied;
    if (released > 0) {
      _profile = _profile.copyWith(
        availableSlots: _profile.availableSlots + released,
      );
    }
    final updated = current.copyWith(maxSlots: occupied, isCompleted: true);
    _binders[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteBinder(String binderId) async {
    final index = _binders.indexWhere((b) => b.id == binderId);
    if (index == -1) {
      return;
    }
    final removed = _binders.removeAt(index);
    _items.removeWhere((item) => item.binderId == binderId);
    if (removed.maxSlots > 0) {
      _profile = _profile.copyWith(
        availableSlots: _profile.availableSlots + removed.maxSlots,
      );
    }
  }

  @override
  Future<ItemModel> addItem(ItemModel item) async {
    final binder = await _requireBinder(item.binderId);
    if (item.collectionCode != binder.collectionCode) {
      throw CollectionMismatchException(
        expectedCollectionCode: binder.collectionCode,
        actualCollectionCode: item.collectionCode,
      );
    }
    if (item.positionIndex < 0 || item.positionIndex >= binder.maxSlots) {
      throw const BinderCapacityException();
    }
    if (_items.any(
      (current) =>
          current.binderId == item.binderId &&
          current.positionIndex == item.positionIndex,
    )) {
      throw const ItemPositionException();
    }
    if (_items.where((current) => current.binderId == binder.id).length >=
        binder.maxSlots) {
      throw const BinderCapacityException();
    }

    final saved = ItemModel(
      id: item.id,
      binderId: item.binderId,
      userId: binder.userId,
      collectionCode: item.collectionCode,
      sourceType: item.sourceType,
      externalId: item.externalId,
      name: item.name,
      imageUrl: item.imageUrl,
      isFoil: item.isFoil,
      condition: item.condition,
      estimatedPrice: item.estimatedPrice,
      positionIndex: item.positionIndex,
      metadata: item.metadata,
      notes: item.notes,
      createdAt: item.createdAt,
    );
    _items.add(saved);
    return saved;
  }

  @override
  Future<ItemModel> updateItem(ItemModel item) async {
    final index = _items.indexWhere((current) => current.id == item.id);
    if (index == -1) {
      throw const BinderRepositoryException('Item not found.');
    }
    final binder = await _requireBinder(item.binderId);
    if (item.collectionCode != binder.collectionCode) {
      throw CollectionMismatchException(
        expectedCollectionCode: binder.collectionCode,
        actualCollectionCode: item.collectionCode,
      );
    }
    if (item.positionIndex < 0 || item.positionIndex >= binder.maxSlots) {
      throw const BinderCapacityException();
    }
    if (_items.any(
      (current) =>
          current.id != item.id &&
          current.binderId == item.binderId &&
          current.positionIndex == item.positionIndex,
    )) {
      throw const ItemPositionException();
    }
    _items[index] = item;
    return item;
  }

  @override
  Future<void> swapItemPositions({
    required String binderId,
    required int fromPosition,
    required int toPosition,
  }) async {
    if (fromPosition == toPosition) {
      return;
    }
    final binder = await _requireBinder(binderId);
    if (fromPosition < 0 ||
        toPosition < 0 ||
        fromPosition >= binder.maxSlots ||
        toPosition >= binder.maxSlots) {
      throw const BinderCapacityException();
    }
    final fromIdx = _items.indexWhere(
      (it) => it.binderId == binderId && it.positionIndex == fromPosition,
    );
    if (fromIdx == -1) {
      return;
    }
    final toIdx = _items.indexWhere(
      (it) => it.binderId == binderId && it.positionIndex == toPosition,
    );
    final moving = _items[fromIdx];
    if (toIdx == -1) {
      _items[fromIdx] = moving.copyWith(positionIndex: toPosition);
    } else {
      final target = _items[toIdx];
      _items[fromIdx] = moving.copyWith(positionIndex: toPosition);
      _items[toIdx] = target.copyWith(positionIndex: fromPosition);
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await moveItemToTrash(itemId);
  }

  @override
  Future<List<TrashedItemRecord>> getTrashedItems() async {
    final sorted = List<TrashedItemRecord>.from(_trashedItems)
      ..sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<TrashedItemRecord?> moveItemToTrash(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      return null;
    }
    final removed = _items.removeAt(index);
    final binder = await getBinder(removed.binderId);
    final record = TrashedItemRecord(
      item: removed,
      binderTitle: binder?.title ?? 'Vitrina',
      deletedAt: DateTime.now().toUtc(),
    );
    _trashedItems.removeWhere((r) => r.item.id == itemId);
    _trashedItems.add(record);
    return record;
  }

  @override
  Future<ItemModel> restoreItemFromTrash(String itemId) async {
    final trashIdx = _trashedItems.indexWhere((r) => r.item.id == itemId);
    if (trashIdx == -1) {
      throw const BinderRepositoryException('Item not found in trash.');
    }
    final record = _trashedItems[trashIdx];
    var targetBinder = await getBinder(record.item.binderId);
    targetBinder ??= _binders
        .where((b) => b.collectionCode == record.item.collectionCode)
        .firstOrNull;
    if (targetBinder == null) {
      throw const BinderRepositoryException('Target binder unavailable.');
    }

    final occupied = _items
        .where((it) => it.binderId == targetBinder!.id)
        .map((it) => it.positionIndex)
        .toSet();
    int? targetSlot;
    if (record.item.binderId == targetBinder.id &&
        record.item.positionIndex >= 0 &&
        record.item.positionIndex < targetBinder.maxSlots &&
        !occupied.contains(record.item.positionIndex)) {
      targetSlot = record.item.positionIndex;
    } else {
      for (var s = 0; s < targetBinder.maxSlots; s++) {
        if (!occupied.contains(s)) {
          targetSlot = s;
          break;
        }
      }
    }
    if (targetSlot == null) {
      throw const BinderCapacityException();
    }

    final restored = ItemModel(
      id: record.item.id,
      binderId: targetBinder.id,
      userId: targetBinder.userId,
      collectionCode: record.item.collectionCode,
      sourceType: record.item.sourceType,
      externalId: record.item.externalId,
      name: record.item.name,
      imageUrl: record.item.imageUrl,
      isFoil: record.item.isFoil,
      condition: record.item.condition,
      estimatedPrice: record.item.estimatedPrice,
      positionIndex: targetSlot,
      metadata: record.item.metadata,
      notes: record.item.notes,
      createdAt: record.item.createdAt,
    );
    _trashedItems.removeAt(trashIdx);
    _items.add(restored);
    return restored;
  }

  @override
  Future<void> permanentlyDeleteFromTrash(String itemId) async {
    _trashedItems.removeWhere((r) => r.item.id == itemId);
  }

  @override
  Future<void> emptyTrash() async {
    _trashedItems.clear();
  }

  @override
  Future<BinderModel?> getPublicBinder(String binderId) async {
    final binder = await getBinder(binderId);
    if (binder == null || !binder.isPublic) {
      return null;
    }
    return binder;
  }

  Future<BinderModel> _requireBinder(String binderId) async {
    final binder = await getBinder(binderId);
    if (binder == null) {
      throw const BinderRepositoryException('Binder not found.');
    }
    return binder;
  }

  String _newId(String prefix) => '$prefix-${_nextId++}';

  static ProfileModel get _defaultProfile => ProfileModel(
    id: '00000000-0000-0000-0000-000000000010',
    username: 'auracollector',
    displayName: 'Aura Collector',
    tradeContact: '@aura_trades_cl',
    preferredLanguage: 'es',
    isPro: false,
    isAdmin: false,
    extraBinderCredits: 0,
    createdAt: DateTime.utc(2026, 1, 1),
  );

  static List<BinderModel> get _defaultBinders => [
    BinderModel(
      id: 'main-binder',
      userId: _defaultProfile.id,
      title: 'Mis Commanders',
      family: 'cards',
      collectionCode: 'magic',
      gridFormat: '3x3',
      maxSlots: AppConstants.standardBinderSlots,
      isFreeTier: true,
      theme: 'obsidian_gold',
      isPublic: true,
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    BinderModel(
      id: 'pokemon-binder',
      userId: _defaultProfile.id,
      title: 'Pokémon 151',
      family: 'cards',
      collectionCode: 'pokemon',
      gridFormat: '3x3',
      maxSlots: AppConstants.standardBinderSlots,
      isFreeTier: false,
      theme: 'obsidian_gold',
      isPublic: true,
      createdAt: DateTime.utc(2026, 1, 2),
    ),
  ];

  static List<ItemModel> get _defaultItems => [
    ItemModel(
      id: 'magic-sol-ring',
      binderId: 'main-binder',
      userId: _defaultProfile.id,
      collectionCode: 'magic',
      sourceType: 'api_scryfall',
      externalId: '1f3c3a6b-5c7d-4d4d-8e90-123456789abc',
      name: 'Sol Ring',
      imageUrl:
          'https://cards.scryfall.io/normal/front/2/c/2c3bb0c0-ffbc-48ed-9a23-1f8dcce6b91e.jpg',
      isFoil: true,
      condition: 'NM',
      estimatedPrice: 24.9,
      positionIndex: 0,
      metadata: const {
        'expansion': 'Commander Masters',
        'number': '396',
        'rarity': 'Mythic',
        'type': 'Artifact',
        'artist': 'Mark Tedin',
      },
      notes: 'Foil Commander staple.',
      createdAt: DateTime.utc(2026, 1, 3),
    ),
    ItemModel(
      id: 'pokemon-151',
      binderId: 'pokemon-binder',
      userId: _defaultProfile.id,
      collectionCode: 'pokemon',
      sourceType: 'api_tcgdex',
      externalId: 'sv3pt5-151',
      name: 'Mew ex',
      imageUrl: 'https://assets.tcgdex.net/en/sv/sv03.5/151/high.webp',
      isFoil: true,
      condition: 'NM',
      estimatedPrice: 68.5,
      positionIndex: 0,
      metadata: const {
        'expansion': 'Pokémon 151',
        'number': '151/165',
        'rarity': 'Special Illustration Rare',
        'type': 'Basic Pokémon',
        'artist': 'Akira Egawa',
      },
      notes: 'A central piece in the 151 collection.',
      createdAt: DateTime.utc(2026, 1, 4),
    ),
  ];
}

extension on ProfileModel {
  ProfileModel copyWithDemoPro() => ProfileModel(
    id: id,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
    tradeContact: tradeContact,
    preferredLanguage: preferredLanguage,
    isPro: true,
    isAdmin: isAdmin,
    extraBinderCredits: extraBinderCredits,
    revenuecatAppUserId: revenuecatAppUserId,
    createdAt: createdAt,
  );
}
