import '../../../../core/models/item_model.dart';
import '../../binder/data/repositories/binder_repository.dart';
import 'repositories/card_strategy_repository.dart';

class MockCardStrategyRepository implements CardStrategyRepository {
  const MockCardStrategyRepository({this.binderRepository});

  final BinderRepository? binderRepository;

  @override
  Future<CardStrategyAnalysis> analyzeItem({
    required ItemModel item,
    required String targetLanguage,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final isSpanish = targetLanguage == 'es';
    final isPortuguese = targetLanguage == 'pt';
    final isJapanese = targetLanguage == 'ja';

    final rules =
        (item.metadata['oracleText'] ?? item.metadata['oracle_text'] ?? '')
            .toString()
            .toLowerCase();
    final cardType =
        (item.metadata['type'] ?? item.metadata['card_type'] ?? '')
            .toString()
            .toLowerCase();
    final combined = '$rules $cardType ${item.name.toLowerCase()}';

    final isRamp =
        combined.contains('add ') ||
        combined.contains('mana') ||
        combined.contains('energy') ||
        combined.contains('artifact');
    final isDraw =
        combined.contains('draw') ||
        combined.contains('search') ||
        combined.contains('scry');
    final isRemoval =
        combined.contains('destroy') ||
        combined.contains('exile') ||
        combined.contains('counter') ||
        combined.contains('damage');

    // Cross-reference with cards already owned in the user's binders.
    final ownedSynergies = <ComboSynergy>[];
    if (binderRepository != null) {
      try {
        final binders = await binderRepository!.getBinders();
        for (final binder in binders) {
          if (binder.collectionCode != item.collectionCode) {
            continue;
          }
          final items = await binderRepository!.getItems(binder.id);
          for (final other in items) {
            if (other.id == item.id) {
              continue;
            }
            ownedSynergies.add(
              ComboSynergy(
                cardName: other.name,
                reason: isSpanish
                    ? 'Ya la tienes en «${binder.title}» (bolsillo #${other.positionIndex + 1}) y comparte colección con ${item.name}.'
                    : isPortuguese
                    ? 'Já está em «${binder.title}» (slot #${other.positionIndex + 1}) e combina com ${item.name}.'
                    : isJapanese
                    ? '「${binder.title}」(#${other.positionIndex + 1})に所持しており、${item.name}と相性が良いです。'
                    : 'Already owned in «${binder.title}» (slot #${other.positionIndex + 1}) and pairs with ${item.name}.',
              ),
            );
            if (ownedSynergies.length >= 2) {
              break;
            }
          }
          if (ownedSynergies.length >= 2) {
            break;
          }
        }
      } catch (_) {
        // Ignore repository errors and fall back to curated staples.
      }
    }

    if (item.collectionCode == 'magic') {
      final archetypes = <String>[
        if (isRamp)
          (isSpanish ? 'Commander Ramp' : 'Commander Ramp')
        else if (isRemoval)
          (isSpanish ? 'Control / Interacción' : 'Control / Interaction')
        else if (isDraw)
          (isSpanish ? 'Motor de Robo' : 'Card Advantage Engine')
        else
          (isSpanish ? 'Midrange Valor' : 'Midrange Value'),
        if (cardType.contains('artifact'))
          (isSpanish ? 'Artifact Storm' : 'Artifact Storm')
        else if (cardType.contains('creature'))
          (isSpanish ? 'Aggro / Combat' : 'Aggro / Combat')
        else
          (isSpanish ? 'Sinergia Temática' : 'Theme Synergy'),
        if (isJapanese) '統率者戦 (EDH)' else 'Commander (EDH)',
      ];

      final fallbackStaples = isSpanish
          ? [
              if (isRamp)
                const ComboSynergy(
                  cardName: 'Arcane Signet',
                  reason:
                      'Acelera maná colorido desde turno 2 junto a tu aceleración.',
                )
              else if (isRemoval)
                const ComboSynergy(
                  cardName: 'Snapcaster Mage',
                  reason:
                      'Permite reutilizar tus hechizos de interacción desde el cementerio.',
                )
              else
                const ComboSynergy(
                  cardName: 'Rhystic Study',
                  reason:
                      'Convierte cada jugada rival en ventaja de cartas constante.',
                ),
              const ComboSynergy(
                cardName: 'Unwinding Clock',
                reason:
                    'Endereza tus artefactos en cada turno rival para multiplicar recursos.',
              ),
              const ComboSynergy(
                cardName: 'Mystic Forge',
                reason:
                    'Convierte la ventaja de maná en robo continuo desde el tope del mazo.',
              ),
            ]
          : isPortuguese
          ? const [
              ComboSynergy(
                cardName: 'Arcane Signet',
                reason:
                    'Acelera mana colorido desde o turno 2 junto à aceleração incolor.',
              ),
              ComboSynergy(
                cardName: 'Unwinding Clock',
                reason: 'Desvira seus artefatos no turno de cada oponente.',
              ),
              ComboSynergy(
                cardName: 'Mystic Forge',
                reason:
                    'Converte mana extra em vantagem contínua do topo do grimório.',
              ),
            ]
          : isJapanese
          ? const [
              ComboSynergy(
                cardName: 'Arcane Signet',
                reason: '無色マナ加速と合わせて2ターン目から色マナを確保できます。',
              ),
              ComboSynergy(
                cardName: 'Unwinding Clock',
                reason: '各対戦相手のターンにアーティファクトをアンタップし続けます。',
              ),
              ComboSynergy(
                cardName: 'Mystic Forge',
                reason: '余剰マナをライブラリートップからの連続展開に変換します。',
              ),
            ]
          : const [
              ComboSynergy(
                cardName: 'Arcane Signet',
                reason:
                    'Fixes colored mana from turn 2 alongside colorless acceleration.',
              ),
              ComboSynergy(
                cardName: 'Unwinding Clock',
                reason:
                    'Untaps your artifacts on every opponent turn to double output.',
              ),
              ComboSynergy(
                cardName: 'Mystic Forge',
                reason:
                    'Converts excess mana into continuous top-deck card advantage.',
              ),
            ];

      final merged = [...ownedSynergies];
      for (final staple in fallbackStaples) {
        if (merged.length >= 3) {
          break;
        }
        if (!merged.any((s) => s.cardName == staple.cardName)) {
          merged.add(staple);
        }
      }

      return CardStrategyAnalysis(
        archetypes: archetypes,
        synergies: merged,
        tacticalTip: isSpanish
            ? (isRamp
                  ? 'Prioriza jugar ${item.name} temprano solo si tu mano ya tiene robo o protección.'
                  : isRemoval
                  ? 'Guarda ${item.name} para cortar la pieza clave de combo o motor del rival.'
                  : 'Coordina ${item.name} con aceleración de maná para maximizar su impacto en mesa.')
            : isPortuguese
            ? 'Use ${item.name} no momento certo para maximizar sua vantagem de recursos.'
            : isJapanese
            ? '${item.name}は手札のドローや防御手段と合わせて展開しましょう。'
            : 'Sequence ${item.name} alongside card draw or protection for maximum impact.',
      );
    }

    if (item.collectionCode == 'pokemon') {
      final fallback = isSpanish
          ? const [
              ComboSynergy(
                cardName: 'Gardevoir ex',
                reason:
                    'Recarga energías psíquicas desde el descarte en el mismo turno.',
              ),
              ComboSynergy(
                cardName: 'Radiant Greninja',
                reason:
                    'Alimenta el descarte mientras acelera el robo de piezas clave.',
              ),
              ComboSynergy(
                cardName: 'Counter Catcher',
                reason:
                    'Permite rematar Pokémon clave en banca cuando vas por detrás en premios.',
              ),
            ]
          : const [
              ComboSynergy(
                cardName: 'Gardevoir ex',
                reason:
                    'Accelerates Psychic Energy from the discard pile in one turn.',
              ),
              ComboSynergy(
                cardName: 'Radiant Greninja',
                reason:
                    'Fuels the discard pile while drawing into key combo pieces.',
              ),
              ComboSynergy(
                cardName: 'Counter Catcher',
                reason:
                    'Targets key benched threats when trailing in Prize cards.',
              ),
            ];
      final merged = [...ownedSynergies];
      for (final staple in fallback) {
        if (merged.length >= 3) {
          break;
        }
        if (!merged.any((s) => s.cardName == staple.cardName)) {
          merged.add(staple);
        }
      }
      return CardStrategyAnalysis(
        archetypes: isSpanish
            ? const ['Psíquico Turbo', 'Control de Banca', 'Box Estratégica']
            : const ['Psychic Turbo', 'Bench Control', 'Toolbox'],
        synergies: merged,
        tacticalTip: isSpanish
            ? 'Usa ${item.name} como soporte de consistencia al final de la partida para evitar quedarte sin mano.'
            : 'Hold ${item.name} as a late-game consistency engine to recover from hand disruption.',
      );
    }

    final genericFallback = isSpanish
        ? [
            ComboSynergy(
              cardName: '${item.name} · Soporte I',
              reason:
                  'Potencia la consistencia temática alrededor de ${item.name}.',
            ),
            const ComboSynergy(
              cardName: 'Búsqueda de Mazo',
              reason: 'Mejora la probabilidad de robar tu pieza principal a tiempo.',
            ),
            const ComboSynergy(
              cardName: 'Protección de Mesa',
              reason: 'Asegura que tu inversión de recursos permanezca activa.',
            ),
          ]
        : [
            ComboSynergy(
              cardName: '${item.name} · Support I',
              reason: 'Reinforces thematic consistency around ${item.name}.',
            ),
            const ComboSynergy(
              cardName: 'Deck Tutor',
              reason: 'Increases consistency finding your centerpiece on curve.',
            ),
            const ComboSynergy(
              cardName: 'Board Protection',
              reason: 'Keeps your key investment safe from opponent removal.',
            ),
          ];

    final merged = [...ownedSynergies];
    for (final staple in genericFallback) {
      if (merged.length >= 3) {
        break;
      }
      merged.add(staple);
    }

    return CardStrategyAnalysis(
      archetypes: isSpanish
          ? const ['Colección Temática', 'Exhibición Competitiva']
          : const ['Themed Showcase', 'Competitive Display'],
      synergies: merged,
      tacticalTip: isSpanish
          ? 'Mantén ${item.name} protegida en tu vitrina y combínala con cartas de consistencia.'
          : 'Keep ${item.name} protected and pair it with consistency engines.',
    );
  }
}
