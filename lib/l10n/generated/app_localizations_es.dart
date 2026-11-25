// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AuraDeck';

  @override
  String get welcomeTitle => 'Tu colección merece su propio aura';

  @override
  String get welcomeSubtitle =>
      'Organiza, exhibe y comparte cartas y objetos de colección en una vitrina diseñada para ti.';

  @override
  String get selectLanguage => 'Elige tu idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageJapanese => '日本語';

  @override
  String get beginButton => 'Comenzar';

  @override
  String get auraLogoDescription => 'Sigilo cromático de AuraDeck';

  @override
  String get yourCollection => 'Tus carpetas';

  @override
  String get collectionSubtitle =>
      'Cada pieza tiene una historia. Dale su lugar.';

  @override
  String binderSummary(String grid, int slots) {
    return '$grid · $slots espacios';
  }

  @override
  String emptySlot(int number) {
    return 'Espacio vacío $number';
  }

  @override
  String get addBinderButton => 'Nueva carpeta';

  @override
  String get genericError =>
      'No pudimos cargar tu colección. Inténtalo de nuevo.';

  @override
  String get retryButton => 'Reintentar';
}
