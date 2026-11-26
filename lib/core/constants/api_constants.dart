abstract final class ApiConstants {
  // Catálogo Pokémon (TCGdex)
  static const String tcgdexHost = 'api.tcgdex.net';
  static String tcgdexCardsPath(String languageCode) =>
      '/v2/$languageCode/cards';

  // Catálogo Magic: The Gathering (Scryfall)
  static const String scryfallHost = 'api.scryfall.com';
  static const String scryfallSearchPath = '/cards/search';
  static const String scryfallUserAgent = 'AuraDeck/1.0';

  // Catálogo Yu-Gi-Oh! (YGOPRODeck)
  static const String ygoprodeckHost = 'db.ygoprodeck.com';
  static const String ygoprodeckCardInfoPath = '/api/v7/cardinfo.php';

  // Formatos y capacidades oficiales de carpetas
  static const List<String> supportedGridFormats = ['2x2', '3x3', '4x3'];
  static const int compactBinderSlots = 160;
  static const int standardBinderSlots = 360;
  static const int masterSetXlSlots = 480;

  // Límites operativos del MVP
  static const int searchDebounceMs = 500;
  static const Duration apiTimeout = Duration(seconds: 12);
  static const int freeAiAnalysesPerDay = 3;
}
