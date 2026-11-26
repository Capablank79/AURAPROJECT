import '../../../../core/models/item_model.dart';

class ComboSynergy {
  const ComboSynergy({required this.cardName, required this.reason});

  final String cardName;
  final String reason;
}

class CardStrategyAnalysis {
  const CardStrategyAnalysis({
    required this.archetypes,
    required this.synergies,
    required this.tacticalTip,
  });

  final List<String> archetypes;
  final List<ComboSynergy> synergies;
  final String tacticalTip;
}

abstract interface class CardStrategyRepository {
  Future<CardStrategyAnalysis> analyzeItem({
    required ItemModel item,
    required String targetLanguage,
  });
}
