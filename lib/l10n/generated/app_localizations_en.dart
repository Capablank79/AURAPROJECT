// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AuraDeck';

  @override
  String get welcomeTitle => 'Your collection deserves its own aura';

  @override
  String get welcomeSubtitle =>
      'Organize, showcase, and share cards and collectibles in a display built for you.';

  @override
  String get selectLanguage => 'Choose your language';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageJapanese => '日本語';

  @override
  String get beginButton => 'Get started';

  @override
  String get auraLogoDescription => 'AuraDeck chromatic sigil';

  @override
  String get yourCollection => 'Your binders';

  @override
  String get collectionSubtitle => 'Every piece has a story. Give it a place.';

  @override
  String binderSummary(String grid, int slots) {
    return '$grid · $slots slots';
  }

  @override
  String emptySlot(int number) {
    return 'Empty slot $number';
  }

  @override
  String get addBinderButton => 'New binder';

  @override
  String get genericError =>
      'We could not load your collection. Please try again.';

  @override
  String get retryButton => 'Retry';
}
