// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'AuraDeck';

  @override
  String get welcomeTitle => 'コレクションにふさわしいオーラを';

  @override
  String get welcomeSubtitle => 'カードやコレクションを、自分だけの展示棚で整理・公開・共有できます。';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageJapanese => '日本語';

  @override
  String get beginButton => 'はじめる';

  @override
  String get auraLogoDescription => 'AuraDeck の虹色の紋章';

  @override
  String get yourCollection => 'あなたのバインダー';

  @override
  String get collectionSubtitle => 'すべての一品に物語を。ふさわしい場所を。';

  @override
  String binderSummary(String grid, int slots) {
    return '$grid・$slots スロット';
  }

  @override
  String emptySlot(int number) {
    return '空きスロット $number';
  }

  @override
  String get addBinderButton => '新しいバインダー';

  @override
  String get genericError => 'コレクションを読み込めませんでした。もう一度お試しください。';

  @override
  String get retryButton => '再試行';
}
