import 'package:flutter/material.dart';

import '../theme/aura_colors.dart';

enum CollectionFamily {
  cards('cards'),
  objects('objects');

  const CollectionFamily(this.code);
  final String code;

  static CollectionFamily fromCode(String code) {
    return code == 'objects'
        ? CollectionFamily.objects
        : CollectionFamily.cards;
  }
}

enum CatalogProvider {
  scryfall('api_scryfall'),
  tcgdex('api_tcgdex'),
  ygoprodeck('api_ygoprodeck');

  const CatalogProvider(this.sourceType);
  final String sourceType;
}

class CollectionSpec {
  const CollectionSpec({
    required this.code,
    required this.family,
    required this.monogram,
    required this.icon,
    required this.accentColor,
    this.catalogProvider,
    this.requiresCustomName = false,
  });

  final String code;
  final CollectionFamily family;
  final String monogram;
  final IconData icon;
  final Color accentColor;
  final CatalogProvider? catalogProvider;
  final bool requiresCustomName;

  bool get supportsApiSearch => catalogProvider != null;
  bool get supportsCardScanner => catalogProvider != null;
  bool get allowsManualPhoto => true;
}

abstract final class CollectionRegistry {
  /// Orden estricto: Magic primero, Pokémon segundo, luego los TCG más famosos
  /// y finalmente opción abierta ("Otro juego de cartas…").
  static const List<CollectionSpec> cardCollections = [
    CollectionSpec(
      code: 'magic',
      family: CollectionFamily.cards,
      monogram: 'M',
      icon: Icons.auto_fix_high,
      accentColor: Color(0xFFF3A55A),
      catalogProvider: CatalogProvider.scryfall,
    ),
    CollectionSpec(
      code: 'pokemon',
      family: CollectionFamily.cards,
      monogram: 'P',
      icon: Icons.catching_pokemon,
      accentColor: AuraColors.solarGold,
      catalogProvider: CatalogProvider.tcgdex,
    ),
    CollectionSpec(
      code: 'yugioh',
      family: CollectionFamily.cards,
      monogram: 'Y',
      icon: Icons.change_history,
      accentColor: Color(0xFFC58BFF),
      catalogProvider: CatalogProvider.ygoprodeck,
    ),
    CollectionSpec(
      code: 'one_piece',
      family: CollectionFamily.cards,
      monogram: 'OP',
      icon: Icons.explore_outlined,
      accentColor: Color(0xFFFF6B6B),
    ),
    CollectionSpec(
      code: 'lorcana',
      family: CollectionFamily.cards,
      monogram: 'L',
      icon: Icons.auto_awesome,
      accentColor: AuraColors.manaCyan,
    ),
    CollectionSpec(
      code: 'digimon',
      family: CollectionFamily.cards,
      monogram: 'DG',
      icon: Icons.memory,
      accentColor: AuraColors.emeraldAura,
    ),
    CollectionSpec(
      code: 'dragon_ball',
      family: CollectionFamily.cards,
      monogram: 'DB',
      icon: Icons.bolt,
      accentColor: Color(0xFFFF922B),
    ),
    CollectionSpec(
      code: 'star_wars',
      family: CollectionFamily.cards,
      monogram: 'SW',
      icon: Icons.public,
      accentColor: Color(0xFF74C0FC),
    ),
    CollectionSpec(
      code: 'fab',
      family: CollectionFamily.cards,
      monogram: 'FB',
      icon: Icons.shield_outlined,
      accentColor: Color(0xFFE599F7),
    ),
    CollectionSpec(
      code: 'naruto',
      family: CollectionFamily.cards,
      monogram: 'N',
      icon: Icons.local_fire_department_outlined,
      accentColor: Color(0xFFFFA94D),
    ),
    CollectionSpec(
      code: 'other_card',
      family: CollectionFamily.cards,
      monogram: '+',
      icon: Icons.style_outlined,
      accentColor: AuraColors.champagneGold,
      requiresCustomName: true,
    ),
  ];

  static const List<CollectionSpec> objectCollections = [
    CollectionSpec(
      code: 'figures',
      family: CollectionFamily.objects,
      monogram: 'FG',
      icon: Icons.toys_outlined,
      accentColor: AuraColors.psychicMagenta,
    ),
    CollectionSpec(
      code: 'comics',
      family: CollectionFamily.objects,
      monogram: 'CM',
      icon: Icons.menu_book_outlined,
      accentColor: AuraColors.manaCyan,
    ),
    CollectionSpec(
      code: 'retro_games',
      family: CollectionFamily.objects,
      monogram: 'RG',
      icon: Icons.sports_esports_outlined,
      accentColor: AuraColors.emeraldAura,
    ),
    CollectionSpec(
      code: 'other_object',
      family: CollectionFamily.objects,
      monogram: '+',
      icon: Icons.inventory_2_outlined,
      accentColor: AuraColors.champagneGold,
      requiresCustomName: true,
    ),
  ];

  static List<CollectionSpec> get all => [
    ...cardCollections,
    ...objectCollections,
  ];

  static List<CollectionSpec> forFamily(CollectionFamily family) {
    return switch (family) {
      CollectionFamily.cards => cardCollections,
      CollectionFamily.objects => objectCollections,
    };
  }

  static CollectionSpec byCode(String code) {
    for (final spec in all) {
      if (spec.code == code) {
        return spec;
      }
    }
    if (code == 'custom') {
      return objectCollections.first;
    }
    return CollectionSpec(
      code: code,
      family: CollectionFamily.cards,
      monogram: code.isEmpty ? '?' : code.substring(0, 1).toUpperCase(),
      icon: Icons.style_outlined,
      accentColor: AuraColors.champagneGold,
    );
  }
}
