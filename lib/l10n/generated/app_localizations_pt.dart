// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AuraDeck';

  @override
  String get welcomeTitle => 'Sua coleção merece uma aura própria';

  @override
  String get welcomeSubtitle =>
      'Organize, exiba e compartilhe cartas e colecionáveis em uma vitrine feita para você.';

  @override
  String get selectLanguage => 'Escolha seu idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageJapanese => '日本語';

  @override
  String get beginButton => 'Começar';

  @override
  String get auraLogoDescription => 'Símbolo cromático da AuraDeck';

  @override
  String get yourCollection => 'Suas pastas';

  @override
  String get collectionSubtitle =>
      'Cada peça tem uma história. Dê a ela um lugar.';

  @override
  String binderSummary(String grid, int slots) {
    return '$grid · $slots espaços';
  }

  @override
  String emptySlot(int number) {
    return 'Espaço vazio $number';
  }

  @override
  String get addBinderButton => 'Nova pasta';

  @override
  String get genericError =>
      'Não foi possível carregar sua coleção. Tente novamente.';

  @override
  String get retryButton => 'Tentar novamente';
}
