/// Helper for preserving TCG symbols/formatting around on-device ML Kit
/// translation and normalizing card-game terminology.
abstract final class TcgTextTranslator {
  static final RegExp _tokenPattern = RegExp(r'\{[^}]+\}|\[[^\]]+\]');

  /// Replaces TCG symbols like `{T}`, `{C}`, `{2}`, `[P]` with numeric
  /// placeholders so ML Kit does not mangle or translate them.
  static ({String masked, List<String> tokens}) maskTokens(String input) {
    final tokens = <String>[];
    final masked = input.replaceAllMapped(_tokenPattern, (match) {
      final index = tokens.length;
      tokens.add(match.group(0)!);
      return '<<$index>>';
    });
    return (masked: masked, tokens: tokens);
  }

  /// Restores previously masked TCG symbols into the translated text.
  static String unmaskTokens(String translated, List<String> tokens) {
    var result = translated;
    for (var i = 0; i < tokens.length; i++) {
      // ML Kit may insert spaces inside/around <<0>>.
      result = result.replaceAll(
        RegExp('<<\\s*$i\\s*>>'),
        tokens[i],
      );
    }
    return result;
  }

  /// Fixes literal machine-translation mistakes in TCG rules text.
  static String postProcess(String text, String targetLangCode) {
    if (targetLangCode == 'es') {
      return _applyReplacements(text, _esPostRules);
    }
    if (targetLangCode == 'pt') {
      return _applyReplacements(text, _ptPostRules);
    }
    return text;
  }

  /// Lightweight offline dictionary fallback when ML Kit models are unavailable
  /// or not yet downloaded. Returns `null` if no meaningful translation was made.
  static String? fallbackTranslate(String text, String targetLangCode) {
    if (targetLangCode != 'es' && targetLangCode != 'pt') {
      return null;
    }
    final rules = targetLangCode == 'es' ? _esFallbackRules : _ptFallbackRules;
    final lines = text.split('\n');
    final translatedLines = <String>[];
    var changed = false;

    for (final line in lines) {
      var current = line;
      for (final (pattern, replacement) in rules) {
        final next = current.replaceAll(pattern, replacement);
        if (next != current) {
          changed = true;
          current = next;
        }
      }
      translatedLines.add(current);
    }

    if (!changed) {
      return null;
    }
    return translatedLines.join('\n');
  }

  static String _applyReplacements(
    String input,
    List<(RegExp, String)> rules,
  ) {
    var result = input;
    for (final (pattern, replacement) in rules) {
      result = result.replaceAll(pattern, replacement);
    }
    return result;
  }

  static final List<(RegExp, String)> _esPostRules = [
    (RegExp(r'\blibrer[ií]a\b', caseSensitive: false), 'biblioteca'),
    (RegExp(r'\bdeshacer\b', caseSensitive: false), 'enderezar'),
    (RegExp(r'\btocar\b', caseSensitive: false), 'girar'),
    (RegExp(r'\btoque\b', caseSensitive: false), 'gire'),
    (RegExp(r'\baprovechar\b', caseSensitive: false), 'girar'),
    (RegExp(r'\bpiscina de man[aá]\b', caseSensitive: false), 'reserva de maná'),
    (RegExp(r'\bgrupo de man[aá]\b', caseSensitive: false), 'reserva de maná'),
    (RegExp(r'\bcartas de premio\b', caseSensitive: false), 'cartas de Premio'),
    (RegExp(r'\bpila de descarte\b', caseSensitive: false), 'pila de descartes'),
    (RegExp(r'\bnoqueado\b', caseSensitive: false), 'Fuera de Combate'),
    (RegExp(r'\bprimer golpe\b', caseSensitive: false), 'daño primero'),
    (RegExp(r'\bdoble golpe\b', caseSensitive: false), 'daño doble'),
    (RegExp(r'\benlace de vida\b', caseSensitive: false), 'vínculo vital'),
    (RegExp(r'\btoque de muerte\b', caseSensitive: false), 'toque mortal'),
    (RegExp(r'\bpisotear\b', caseSensitive: false), 'arrollar'),
  ];

  static final List<(RegExp, String)> _ptPostRules = [
    (RegExp(r'\blivraria\b', caseSensitive: false), 'grimório'),
    (RegExp(r'\bbiblioteca\b', caseSensitive: false), 'grimório'),
    (RegExp(r'\bdesfazer\b', caseSensitive: false), 'desvirar'),
    (RegExp(r'\btocar\b', caseSensitive: false), 'virar'),
    (RegExp(r'\bpiscina de mana\b', caseSensitive: false), 'reserva de mana'),
    (RegExp(r'\bprimeiro ataque\b', caseSensitive: false), 'iniciativa'),
    (RegExp(r'\bataque duplo\b', caseSensitive: false), 'golpe duplo'),
    (RegExp(r'\batropelar\b', caseSensitive: false), 'atropelar'),
  ];

  static final List<(RegExp, String)> _esFallbackRules = [
    (RegExp(r'\bEnters the battlefield tapped\b', caseSensitive: false), 'Entra al campo de batalla girado'),
    (RegExp(r'\bEnters the battlefield\b', caseSensitive: false), 'Entra al campo de batalla'),
    (RegExp(r'\bSearch your library for\b', caseSensitive: false), 'Busca en tu biblioteca'),
    (RegExp(r'\bShuffle your library\b', caseSensitive: false), 'Baraja tu biblioteca'),
    (RegExp(r'\bDraw a card\b', caseSensitive: false), 'Roba una carta'),
    (RegExp(r'\bDraw two cards\b', caseSensitive: false), 'Roba dos cartas'),
    (RegExp(r'\bDraw (\d+) cards\b', caseSensitive: false), 'Roba \$1 cartas'),
    (RegExp(r'\bDiscard a card\b', caseSensitive: false), 'Descarta una carta'),
    (RegExp(r'\bDiscard your hand\b', caseSensitive: false), 'Descarta tu mano'),
    (RegExp(r'\bDestroy target\b', caseSensitive: false), 'Destruye el objetivo'),
    (RegExp(r'\bExile target\b', caseSensitive: false), 'Exilia el objetivo'),
    (RegExp(r'\bCounter target spell\b', caseSensitive: false), 'Contrarresta el hechizo objetivo'),
    (RegExp(r'\bYou gain (\d+) life\b', caseSensitive: false), 'Ganas \$1 vidas'),
    (RegExp(r'\bdeals (\d+) damage to\b', caseSensitive: false), 'hace \$1 puntos de daño a'),
    (RegExp(r'\bFirst strike\b', caseSensitive: false), 'Daño primero'),
    (RegExp(r'\bDouble strike\b', caseSensitive: false), 'Daño doble'),
    (RegExp(r'\bDeathtouch\b', caseSensitive: false), 'Toque mortal'),
    (RegExp(r'\bLifelink\b', caseSensitive: false), 'Vínculo vital'),
    (RegExp(r'\bVigilance\b', caseSensitive: false), 'Vigilancia'),
    (RegExp(r'\bFlying\b', caseSensitive: false), 'Vuela'),
    (RegExp(r'\bTrample\b', caseSensitive: false), 'Arrollar'),
    (RegExp(r'\bHaste\b', caseSensitive: false), 'Prisa'),
    (RegExp(r'\bHexproof\b', caseSensitive: false), 'Antimaleficio'),
    (RegExp(r'\bMenace\b', caseSensitive: false), 'Amenaza'),
    (RegExp(r'\bReach\b', caseSensitive: false), 'Alcance'),
    (RegExp(r'\bDefender\b', caseSensitive: false), 'Defensor'),
    (RegExp(r'\bAdd\b', caseSensitive: false), 'Agrega'),
    (RegExp(r'\bUntap\b', caseSensitive: false), 'Endereza'),
    (RegExp(r'\bTap\b', caseSensitive: false), 'Gira'),
    (RegExp(r'\buntil end of turn\b', caseSensitive: false), 'hasta el final del turno'),
    (RegExp(r'\bat the beginning of your upkeep\b', caseSensitive: false), 'al comienzo de tu mantenimiento'),
    (RegExp(r'\byour graveyard\b', caseSensitive: false), 'tu cementerio'),
    (RegExp(r'\byour hand\b', caseSensitive: false), 'tu mano'),
    (RegExp(r'\byour library\b', caseSensitive: false), 'tu biblioteca'),
    (RegExp(r'\bActive Pok[eé]mon\b', caseSensitive: false), 'Pokémon Activo'),
    (RegExp(r'\bBenched Pok[eé]mon\b', caseSensitive: false), 'Pokémon en Banca'),
    (RegExp(r'\bdiscard pile\b', caseSensitive: false), 'pila de descartes'),
    (RegExp(r'\bPrize card\b', caseSensitive: false), 'carta de Premio'),
  ];

  static final List<(RegExp, String)> _ptFallbackRules = [
    (RegExp(r'\bEnters the battlefield tapped\b', caseSensitive: false), 'Entra no campo de batalha virado'),
    (RegExp(r'\bEnters the battlefield\b', caseSensitive: false), 'Entra no campo de batalha'),
    (RegExp(r'\bSearch your library for\b', caseSensitive: false), 'Procure em seu grimório'),
    (RegExp(r'\bShuffle your library\b', caseSensitive: false), 'Embaralhe seu grimório'),
    (RegExp(r'\bDraw a card\b', caseSensitive: false), 'Compre um card'),
    (RegExp(r'\bDraw two cards\b', caseSensitive: false), 'Compre dois cards'),
    (RegExp(r'\bFirst strike\b', caseSensitive: false), 'Iniciativa'),
    (RegExp(r'\bDouble strike\b', caseSensitive: false), 'Golpe duplo'),
    (RegExp(r'\bDeathtouch\b', caseSensitive: false), 'Toque mortífero'),
    (RegExp(r'\bLifelink\b', caseSensitive: false), 'Vínculo com a vida'),
    (RegExp(r'\bVigilance\b', caseSensitive: false), 'Vigilância'),
    (RegExp(r'\bFlying\b', caseSensitive: false), 'Voar'),
    (RegExp(r'\bTrample\b', caseSensitive: false), 'Atropelar'),
    (RegExp(r'\bHaste\b', caseSensitive: false), 'Ímpeto'),
    (RegExp(r'\bAdd\b', caseSensitive: false), 'Adicione'),
    (RegExp(r'\bUntap\b', caseSensitive: false), 'Desvire'),
    (RegExp(r'\bTap\b', caseSensitive: false), 'Vire'),
    (RegExp(r'\buntil end of turn\b', caseSensitive: false), 'até o final do turno'),
  ];
}
