import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/deck_model.dart';
import '../../binder/providers/binder_providers.dart';
import '../data/mock_deck_repository.dart';
import '../data/repositories/deck_repository.dart';

final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) => MockDeckRepository(),
);

final decksProvider = AsyncNotifierProvider<DecksController, List<DeckModel>>(
  DecksController.new,
);

class DecksController extends AsyncNotifier<List<DeckModel>> {
  @override
  Future<List<DeckModel>> build() {
    return ref.watch(deckRepositoryProvider).getDecks();
  }

  Future<DeckModel> createDeck({
    required String title,
    required String gameType,
    String? format,
  }) async {
    final created = await ref
        .read(deckRepositoryProvider)
        .createDeck(title: title, gameType: gameType, format: format);
    state = AsyncData(await ref.read(deckRepositoryProvider).getDecks());
    return created;
  }

  Future<void> deleteDeck(String deckId) async {
    await ref.read(deckRepositoryProvider).deleteDeck(deckId);
    state = AsyncData(await ref.read(deckRepositoryProvider).getDecks());
  }

  Future<void> addCard({
    required String deckId,
    required String cardName,
    int cost = 2,
    double estimatedUnitUsd = 4.5,
  }) async {
    await ref.read(deckRepositoryProvider).addCard(
      deckId: deckId,
      cardName: cardName,
      cost: cost,
      estimatedUnitUsd: estimatedUnitUsd,
    );
    state = AsyncData(await ref.read(deckRepositoryProvider).getDecks());
  }

  Future<void> updateQuantity({
    required String deckId,
    required int entryIndex,
    required int delta,
  }) async {
    await ref.read(deckRepositoryProvider).updateCardQuantity(
      deckId: deckId,
      entryIndex: entryIndex,
      delta: delta,
    );
    state = AsyncData(await ref.read(deckRepositoryProvider).getDecks());
  }

  Future<void> importLines({
    required String deckId,
    required String rawText,
  }) async {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);
    final entries = <DeckCardEntry>[];
    final pattern = RegExp(r'^(\d+)x?\s+(.+)$', caseSensitive: false);
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      final qty = match != null ? (int.tryParse(match.group(1)!) ?? 1) : 1;
      final name = match != null ? match.group(2)!.trim() : line;
      entries.add(DeckCardEntry(name: name, quantity: qty));
    }
    await ref
        .read(deckRepositoryProvider)
        .replaceDecklist(deckId: deckId, entries: entries);
    state = AsyncData(await ref.read(deckRepositoryProvider).getDecks());
  }
}

class OwnedCardLocation {
  const OwnedCardLocation({
    required this.binderId,
    required this.itemId,
    required this.binderTitle,
    required this.sheetNumber,
    required this.pocketNumber,
  });

  final String binderId;
  final String itemId;
  final String binderTitle;
  final int sheetNumber;
  final int pocketNumber;

  String get formatted => '$binderTitle · P$sheetNumber #$pocketNumber';
}

class DeckInventoryMatch {
  const DeckInventoryMatch({
    required this.locationsByCardName,
  });

  final Map<String, List<OwnedCardLocation>> locationsByCardName;

  List<OwnedCardLocation> lookup(String cardName) {
    return locationsByCardName[cardName.trim().toLowerCase()] ?? const [];
  }
}

final deckInventoryMatchProvider = FutureProvider<DeckInventoryMatch>((
  ref,
) async {
  final binders = await ref.watch(bindersProvider.future);
  final map = <String, List<OwnedCardLocation>>{};

  for (final binder in binders) {
    final items = await ref.watch(binderItemsProvider(binder.id).future);
    final perSheet = slotsPerSheetForFormat(binder.gridFormat);
    for (final item in items) {
      if (!item.isPhysicallyVerified) {
        continue;
      }
      final key = item.name.trim().toLowerCase();
      final list = map.putIfAbsent(key, () => []);
      list.add(
        OwnedCardLocation(
          binderId: binder.id,
          itemId: item.id,
          binderTitle: binder.title,
          sheetNumber: (item.positionIndex ~/ perSheet) + 1,
          pocketNumber: item.positionIndex + 1,
        ),
      );
    }
  }
  return DeckInventoryMatch(locationsByCardName: map);
});
