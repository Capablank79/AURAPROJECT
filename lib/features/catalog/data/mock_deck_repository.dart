import '../../../core/models/deck_model.dart';
import 'repositories/deck_repository.dart';

class MockDeckRepository implements DeckRepository {
  MockDeckRepository({List<DeckModel>? initialDecks})
    : _decks = List.of(initialDecks ?? _defaultDecks);

  final List<DeckModel> _decks;
  int _nextId = 10;

  @override
  Future<List<DeckModel>> getDecks() async => List.unmodifiable(_decks);

  @override
  Future<DeckModel> createDeck({
    required String title,
    required String gameType,
    String? format,
  }) async {
    final deck = DeckModel(
      id: 'deck-${_nextId++}',
      userId: '00000000-0000-0000-0000-000000000010',
      title: title.trim(),
      gameType: gameType,
      format: format?.trim().isEmpty == true ? null : format?.trim(),
      cardIds: const [],
      entries: const [],
      createdAt: DateTime.now().toUtc(),
    );
    _decks.add(deck);
    return deck;
  }

  @override
  Future<DeckModel> addCard({
    required String deckId,
    required String cardName,
    int cost = 2,
    double estimatedUnitUsd = 4.5,
  }) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index == -1) {
      throw StateError('Deck not found: $deckId');
    }
    final current = _decks[index];
    final normalized = cardName.trim();
    final updatedEntries = List<DeckCardEntry>.from(current.entries);
    final existingIdx = updatedEntries.indexWhere(
      (e) => e.name.toLowerCase() == normalized.toLowerCase(),
    );
    if (existingIdx >= 0) {
      final entry = updatedEntries[existingIdx];
      updatedEntries[existingIdx] = entry.copyWith(
        quantity: entry.quantity + 1,
      );
    } else {
      updatedEntries.add(
        DeckCardEntry(
          name: normalized,
          quantity: 1,
          cost: cost,
          estimatedUnitUsd: estimatedUnitUsd,
        ),
      );
    }
    final updated = current.copyWith(entries: updatedEntries);
    _decks[index] = updated;
    return updated;
  }

  @override
  Future<DeckModel> updateCardQuantity({
    required String deckId,
    required int entryIndex,
    required int delta,
  }) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index == -1) {
      throw StateError('Deck not found: $deckId');
    }
    final current = _decks[index];
    final updatedEntries = List<DeckCardEntry>.from(current.entries);
    if (entryIndex < 0 || entryIndex >= updatedEntries.length) {
      return current;
    }
    final nextQty = updatedEntries[entryIndex].quantity + delta;
    if (nextQty <= 0) {
      updatedEntries.removeAt(entryIndex);
    } else {
      updatedEntries[entryIndex] = updatedEntries[entryIndex].copyWith(
        quantity: nextQty,
      );
    }
    final updated = current.copyWith(entries: updatedEntries);
    _decks[index] = updated;
    return updated;
  }

  @override
  Future<DeckModel> replaceDecklist({
    required String deckId,
    required List<DeckCardEntry> entries,
  }) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index == -1) {
      throw StateError('Deck not found: $deckId');
    }
    final updated = _decks[index].copyWith(entries: entries);
    _decks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    _decks.removeWhere((d) => d.id == deckId);
  }

  static List<DeckModel> get _defaultDecks => [
    DeckModel(
      id: 'deck-commander-1',
      userId: '00000000-0000-0000-0000-000000000010',
      title: 'Commander Staples',
      gameType: 'magic',
      format: 'Commander (EDH)',
      cardIds: const [],
      entries: const [
        DeckCardEntry(
          name: 'Sol Ring',
          quantity: 1,
          cost: 1,
          estimatedUnitUsd: 24.9,
        ),
        DeckCardEntry(
          name: 'Atraxa, Grand Unifier',
          quantity: 1,
          cost: 7,
          estimatedUnitUsd: 42.5,
        ),
        DeckCardEntry(
          name: 'Arcane Signet',
          quantity: 1,
          cost: 2,
          estimatedUnitUsd: 1.5,
        ),
      ],
      createdAt: DateTime.utc(2026, 1, 5),
    ),
  ];
}
