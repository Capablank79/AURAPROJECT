import '../../../../core/models/item_model.dart';
import 'repositories/card_strategy_repository.dart';

class MockCardStrategyRepository implements CardStrategyRepository {
  const MockCardStrategyRepository();

  @override
  Future<CardStrategyAnalysis> analyzeItem({
    required ItemModel item,
    required String targetLanguage,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final isSpanish = targetLanguage == 'es';
    final isPortuguese = targetLanguage == 'pt';
    final isJapanese = targetLanguage == 'ja';

    if (item.collectionCode == 'magic') {
      return CardStrategyAnalysis(
        archetypes: isSpanish
            ? const ['Commander Ramp', 'Artifact Storm', 'Midrange Valor']
            : isPortuguese
            ? const ['Commander Ramp', 'Artifact Storm', 'Midrange']
            : isJapanese
            ? const ['統率者ランプ', 'アーティファクト・ストーム', 'ミッドレンジ']
            : const ['Commander Ramp', 'Artifact Storm', 'Midrange Value'],
        synergies: isSpanish
            ? const [
                ComboSynergy(
                  cardName: 'Arcane Signet',
                  reason:
                      'Acelera maná colorido desde turno 2 junto a tu aceleración incolora.',
                ),
                ComboSynergy(
                  cardName: 'Unwinding Clock',
                  reason:
                      'Endereza tus artefactos en cada turno rival para multiplicar recursos.',
                ),
                ComboSynergy(
                  cardName: 'Mystic Forge',
                  reason:
                      'Convierte la ventaja de maná en robo continuo desde la parte superior del mazo.',
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
              ],
        tacticalTip: isSpanish
            ? 'Prioriza jugarla en turno 1 solo si tu mano ya tiene seguimiento de robo o protección.'
            : isPortuguese
            ? 'Jogue no turno 1 apenas se a mão inicial tiver compra ou proteção.'
            : isJapanese
            ? '初手にドローや防御手段がある場合に1ターン目の展開を優先しましょう。'
            : 'Play it on turn 1 when your opening hand already has card draw or protection.',
      );
    }

    if (item.collectionCode == 'pokemon') {
      return CardStrategyAnalysis(
        archetypes: isSpanish
            ? const ['Psíquico Turbo', 'Control de Banca', 'Box Estratégica']
            : const ['Psychic Turbo', 'Bench Control', 'Toolbox'],
        synergies: isSpanish
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
              ],
        tacticalTip: isSpanish
            ? 'Úsala como soporte de consistencia al final de la partida para evitar quedarte sin mano.'
            : 'Hold it as a late-game consistency engine to recover from hand disruption.',
      );
    }

    return CardStrategyAnalysis(
      archetypes: isSpanish
          ? const ['Colección Temática', 'Exhibición Competitiva']
          : const ['Themed Showcase', 'Competitive Display'],
      synergies: isSpanish
          ? [
              ComboSynergy(
                cardName: '${item.name} · Soporte I',
                reason:
                    'Potencia la consistencia temática alrededor de ${item.name}.',
              ),
              const ComboSynergy(
                cardName: 'Buscador de Piezas',
                reason:
                    'Permite encontrar cartas clave en los primeros turnos.',
              ),
              const ComboSynergy(
                cardName: 'Protección Táctica',
                reason:
                    'Resguarda tus piezas principales frente a respuestas rivales.',
              ),
            ]
          : [
              ComboSynergy(
                cardName: '${item.name} · Support I',
                reason: 'Boosts thematic consistency around ${item.name}.',
              ),
              const ComboSynergy(
                cardName: 'Core Searcher',
                reason: 'Finds your primary playmakers during early turns.',
              ),
              const ComboSynergy(
                cardName: 'Tactical Ward',
                reason:
                    'Protects your centerpiece against opponent interaction.',
              ),
            ],
      tacticalTip: isSpanish
          ? 'Mantén tus piezas clave protegidas y prioriza cartas que aceleren tu plan principal.'
          : 'Protect your centerpiece and pair it with cards that speed up your main plan.',
    );
  }
}
