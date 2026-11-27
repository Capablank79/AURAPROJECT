import '../../../../core/models/deck_model.dart';

abstract interface class DeckRepository {
  Future<List<DeckModel>> getDecks();

  Future<DeckModel> createDeck({
    required String title,
    required String gameType,
    String? format,
  });

  Future<DeckModel> addCard({
    required String deckId,
    required String cardName,
    int cost = 2,
    double estimatedUnitUsd = 4.5,
  });

  Future<DeckModel> updateCardQuantity({
    required String deckId,
    required int entryIndex,
    required int delta,
  });

  Future<DeckModel> replaceDecklist({
    required String deckId,
    required List<DeckCardEntry> entries,
  });

  Future<void> deleteDeck(String deckId);
}
