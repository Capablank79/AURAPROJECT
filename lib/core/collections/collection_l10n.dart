import '../../l10n/generated/app_localizations.dart';
import '../models/binder_model.dart';
import 'collection_registry.dart';

abstract final class CollectionL10n {
  static String familyTitle(AppLocalizations l10n, CollectionFamily family) {
    return switch (family) {
      CollectionFamily.cards => l10n.familyCardsTitle,
      CollectionFamily.objects => l10n.familyObjectsTitle,
    };
  }

  static String familySubtitle(AppLocalizations l10n, CollectionFamily family) {
    return switch (family) {
      CollectionFamily.cards => l10n.familyCardsSubtitle,
      CollectionFamily.objects => l10n.familyObjectsSubtitle,
    };
  }

  static String collectionName(
    AppLocalizations l10n,
    String code, {
    String? customName,
  }) {
    final trimmed = customName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return switch (code) {
      'magic' => l10n.gameMagic,
      'pokemon' => l10n.gamePokemon,
      'yugioh' => l10n.gameYugioh,
      'one_piece' => l10n.gameOnePiece,
      'lorcana' => l10n.gameLorcana,
      'digimon' => l10n.gameDigimon,
      'dragon_ball' => l10n.gameDragonBall,
      'star_wars' => l10n.gameStarWars,
      'fab' => l10n.gameFleshAndBlood,
      'naruto' => l10n.gameNaruto,
      'other_card' => l10n.gameOtherCard,
      'figures' => l10n.objectFigures,
      'comics' => l10n.objectComics,
      'retro_games' => l10n.objectRetroGames,
      'other_object' => l10n.objectOther,
      'custom' => l10n.familyObjectsTitle,
      _ => code,
    };
  }

  static String binderCollectionLabel(
    AppLocalizations l10n,
    BinderModel binder,
  ) {
    return collectionName(
      l10n,
      binder.collectionCode,
      customName: binder.customCollectionName,
    );
  }

  static String suggestedBinderTitle(
    AppLocalizations l10n,
    CollectionSpec? spec, {
    String? customName,
  }) {
    if (spec == null) {
      return l10n.firstBinderNameHint;
    }
    if (spec.code == 'magic') {
      return l10n.magicBinderSuggestion;
    }
    if (spec.code == 'pokemon') {
      return l10n.pokemonBinderSuggestion;
    }
    if (spec.family == CollectionFamily.objects &&
        (customName == null || customName.trim().isEmpty)) {
      return l10n.customBinderSuggestion;
    }
    final label = collectionName(l10n, spec.code, customName: customName);
    return l10n.namedCollectionSuggestion(label);
  }
}
