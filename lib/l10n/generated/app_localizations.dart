import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'AuraDeck'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu colección merece su propio aura'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza, exhibe y comparte cartas y objetos de colección en una vitrina diseñada para ti.'**
  String get welcomeSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'ELIGE TU IDIOMA'**
  String get selectLanguage;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePortuguese.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageJapanese.
  ///
  /// In es, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @beginButton.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get beginButton;

  /// No description provided for @continueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @backButton.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get backButton;

  /// No description provided for @chooseCollectionTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué vas a coleccionar?'**
  String get chooseCollectionTitle;

  /// No description provided for @chooseCollectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una colección para preparar tu primera vitrina gratuita.'**
  String get chooseCollectionSubtitle;

  /// No description provided for @chooseFamilySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige primero la familia. Podrás crear más vitrinas después.'**
  String get chooseFamilySubtitle;

  /// No description provided for @familyCardsTitle.
  ///
  /// In es, this message translates to:
  /// **'Cartas coleccionables'**
  String get familyCardsTitle;

  /// No description provided for @familyCardsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Magic, Pokémon, Yu-Gi-Oh!, One Piece, Lorcana, Naruto y cualquier juego de cartas.'**
  String get familyCardsSubtitle;

  /// No description provided for @familyObjectsTitle.
  ///
  /// In es, this message translates to:
  /// **'Colección de objetos'**
  String get familyObjectsTitle;

  /// No description provided for @familyObjectsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Figuras, cómics, videojuegos retro, estatuas y piezas físicas.'**
  String get familyObjectsSubtitle;

  /// No description provided for @chooseCardGameTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué juego de cartas?'**
  String get chooseCardGameTitle;

  /// No description provided for @chooseCardGameSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La búsqueda y el escáner se activan automáticamente en los juegos con catálogo disponible.'**
  String get chooseCardGameSubtitle;

  /// No description provided for @chooseObjectTypeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tipo de objetos?'**
  String get chooseObjectTypeTitle;

  /// No description provided for @chooseObjectTypeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tus piezas con fotografía optimizada en formato WebP.'**
  String get chooseObjectTypeSubtitle;

  /// No description provided for @selectCardGameLabel.
  ///
  /// In es, this message translates to:
  /// **'Juego de cartas'**
  String get selectCardGameLabel;

  /// No description provided for @selectObjectTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de colección'**
  String get selectObjectTypeLabel;

  /// No description provided for @filterGamesHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar juego…'**
  String get filterGamesHint;

  /// No description provided for @gameMagic.
  ///
  /// In es, this message translates to:
  /// **'Magic: The Gathering'**
  String get gameMagic;

  /// No description provided for @gamePokemon.
  ///
  /// In es, this message translates to:
  /// **'Pokémon TCG'**
  String get gamePokemon;

  /// No description provided for @gameYugioh.
  ///
  /// In es, this message translates to:
  /// **'Yu-Gi-Oh!'**
  String get gameYugioh;

  /// No description provided for @gameOnePiece.
  ///
  /// In es, this message translates to:
  /// **'One Piece Card Game'**
  String get gameOnePiece;

  /// No description provided for @gameLorcana.
  ///
  /// In es, this message translates to:
  /// **'Disney Lorcana'**
  String get gameLorcana;

  /// No description provided for @gameDigimon.
  ///
  /// In es, this message translates to:
  /// **'Digimon Card Game'**
  String get gameDigimon;

  /// No description provided for @gameDragonBall.
  ///
  /// In es, this message translates to:
  /// **'Dragon Ball Super Card Game'**
  String get gameDragonBall;

  /// No description provided for @gameStarWars.
  ///
  /// In es, this message translates to:
  /// **'Star Wars: Unlimited'**
  String get gameStarWars;

  /// No description provided for @gameFleshAndBlood.
  ///
  /// In es, this message translates to:
  /// **'Flesh and Blood'**
  String get gameFleshAndBlood;

  /// No description provided for @gameNaruto.
  ///
  /// In es, this message translates to:
  /// **'Naruto (Kayou / CCG)'**
  String get gameNaruto;

  /// No description provided for @gameOtherCard.
  ///
  /// In es, this message translates to:
  /// **'Otro juego de cartas…'**
  String get gameOtherCard;

  /// No description provided for @objectFigures.
  ///
  /// In es, this message translates to:
  /// **'Figuras y estatuas'**
  String get objectFigures;

  /// No description provided for @objectComics.
  ///
  /// In es, this message translates to:
  /// **'Cómics y manga'**
  String get objectComics;

  /// No description provided for @objectRetroGames.
  ///
  /// In es, this message translates to:
  /// **'Videojuegos y consolas'**
  String get objectRetroGames;

  /// No description provided for @objectOther.
  ///
  /// In es, this message translates to:
  /// **'Otro tipo de colección…'**
  String get objectOther;

  /// No description provided for @customCollectionNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la colección'**
  String get customCollectionNameLabel;

  /// No description provided for @customCollectionNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Mitos y Leyendas, cartas deportivas…'**
  String get customCollectionNameHint;

  /// No description provided for @capabilitySearchBadge.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda'**
  String get capabilitySearchBadge;

  /// No description provided for @capabilityScannerBadge.
  ///
  /// In es, this message translates to:
  /// **'Escáner'**
  String get capabilityScannerBadge;

  /// No description provided for @capabilityManualOnlyBadge.
  ///
  /// In es, this message translates to:
  /// **'Solo manual'**
  String get capabilityManualOnlyBadge;

  /// No description provided for @nameYourShowcaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Dale nombre a tu vitrina'**
  String get nameYourShowcaseTitle;

  /// No description provided for @changeSelectionButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get changeSelectionButton;

  /// No description provided for @showcaseIncludesTitle.
  ///
  /// In es, this message translates to:
  /// **'ESTA VITRINA INCLUYE'**
  String get showcaseIncludesTitle;

  /// No description provided for @includesCatalogSearch.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda en catálogo oficial de {collection}'**
  String includesCatalogSearch(String collection);

  /// No description provided for @includesCameraScanner.
  ///
  /// In es, this message translates to:
  /// **'Escáner de cartas con cámara y lectura local'**
  String get includesCameraScanner;

  /// No description provided for @includesManualWebp.
  ///
  /// In es, this message translates to:
  /// **'Registro fotográfico optimizado WebP + lectura local de título'**
  String get includesManualWebp;

  /// No description provided for @includesSingleCollectionRule.
  ///
  /// In es, this message translates to:
  /// **' Exclusiva para piezas de {collection} (sin mezclas)'**
  String includesSingleCollectionRule(String collection);

  /// No description provided for @namedCollectionSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Mi vitrina de {collection}'**
  String namedCollectionSuggestion(String collection);

  /// No description provided for @firstBinderNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de tu vitrina'**
  String get firstBinderNameLabel;

  /// No description provided for @firstBinderNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Mis Commanders favoritos'**
  String get firstBinderNameHint;

  /// No description provided for @pokemonBinderSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Mi colección Pokémon'**
  String get pokemonBinderSuggestion;

  /// No description provided for @magicBinderSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Mis Commanders favoritos'**
  String get magicBinderSuggestion;

  /// No description provided for @customBinderSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Mi vitrina personal'**
  String get customBinderSuggestion;

  /// No description provided for @createFreeBinderButton.
  ///
  /// In es, this message translates to:
  /// **'Crear mi vitrina gratis'**
  String get createFreeBinderButton;

  /// No description provided for @freeBinderCapacityHint.
  ///
  /// In es, this message translates to:
  /// **'360 espacios · cuadrícula 3×3 · gratis'**
  String get freeBinderCapacityHint;

  /// No description provided for @categoryPokemonDescription.
  ///
  /// In es, this message translates to:
  /// **'Cartas y expansiones de Pokémon TCG.'**
  String get categoryPokemonDescription;

  /// No description provided for @categoryMagicDescription.
  ///
  /// In es, this message translates to:
  /// **'Cartas y ediciones de Magic: The Gathering.'**
  String get categoryMagicDescription;

  /// No description provided for @categoryCustomDescription.
  ///
  /// In es, this message translates to:
  /// **'Figuras, cómics, videojuegos, piezas retro y más.'**
  String get categoryCustomDescription;

  /// No description provided for @selectCategorySemantic.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar {category}'**
  String selectCategorySemantic(String category);

  /// No description provided for @auraLogoDescription.
  ///
  /// In es, this message translates to:
  /// **'Isotipo dorado y halo cromático de AuraDeck'**
  String get auraLogoDescription;

  /// No description provided for @navShowcases.
  ///
  /// In es, this message translates to:
  /// **'Mis vitrinas'**
  String get navShowcases;

  /// No description provided for @navSearchCollection.
  ///
  /// In es, this message translates to:
  /// **'Buscar en mis vitrinas'**
  String get navSearchCollection;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @auraProBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Aura Pro'**
  String get auraProBannerTitle;

  /// No description provided for @auraProBannerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vitrinas ilimitadas y formato Master Set XL'**
  String get auraProBannerSubtitle;

  /// No description provided for @searchMyShowcasesLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar en tus vitrinas'**
  String get searchMyShowcasesLabel;

  /// No description provided for @searchMyShowcasesHint.
  ///
  /// In es, this message translates to:
  /// **'Filtra por nombre de carta u objeto guardado'**
  String get searchMyShowcasesHint;

  /// No description provided for @noStoredItemsFound.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay piezas guardadas que coincidan.'**
  String get noStoredItemsFound;

  /// No description provided for @yourCollection.
  ///
  /// In es, this message translates to:
  /// **'Tus vitrinas'**
  String get yourCollection;

  /// No description provided for @collectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cada pieza tiene una historia. Dale su lugar.'**
  String get collectionSubtitle;

  /// No description provided for @binderSummary.
  ///
  /// In es, this message translates to:
  /// **'{grid} · {slots} espacios'**
  String binderSummary(String grid, int slots);

  /// No description provided for @emptySlot.
  ///
  /// In es, this message translates to:
  /// **'Espacio vacío {number}'**
  String emptySlot(int number);

  /// No description provided for @addBinderButton.
  ///
  /// In es, this message translates to:
  /// **'Nueva vitrina'**
  String get addBinderButton;

  /// No description provided for @chooseFirstCollectionButton.
  ///
  /// In es, this message translates to:
  /// **'Elegir mi primera colección'**
  String get chooseFirstCollectionButton;

  /// No description provided for @emptyCollectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu vitrina comienza aquí'**
  String get emptyCollectionTitle;

  /// No description provided for @emptyCollectionMessage.
  ///
  /// In es, this message translates to:
  /// **'Elige qué coleccionar y crea gratis tu primera vitrina de 360 espacios.'**
  String get emptyCollectionMessage;

  /// No description provided for @changeLanguage.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get changeLanguage;

  /// No description provided for @createBinderTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva vitrina'**
  String get createBinderTitle;

  /// No description provided for @binderTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la vitrina'**
  String get binderTitleLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoryLabel;

  /// No description provided for @categoryPokemon.
  ///
  /// In es, this message translates to:
  /// **'Pokémon'**
  String get categoryPokemon;

  /// No description provided for @categoryMagic.
  ///
  /// In es, this message translates to:
  /// **'Magic'**
  String get categoryMagic;

  /// No description provided for @categoryCustom.
  ///
  /// In es, this message translates to:
  /// **'Objetos físicos'**
  String get categoryCustom;

  /// No description provided for @publicBinderLabel.
  ///
  /// In es, this message translates to:
  /// **'Vitrina pública'**
  String get publicBinderLabel;

  /// No description provided for @publicBinderHint.
  ///
  /// In es, this message translates to:
  /// **'Permite verla mediante un enlace de solo lectura.'**
  String get publicBinderHint;

  /// No description provided for @createButton.
  ///
  /// In es, this message translates to:
  /// **'Crear vitrina'**
  String get createButton;

  /// No description provided for @createBinderError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos crear la vitrina. Revisa los datos e inténtalo de nuevo.'**
  String get createBinderError;

  /// No description provided for @freeTierLimitTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu vitrina gratuita ya está en uso'**
  String get freeTierLimitTitle;

  /// No description provided for @freeTierLimitMessage.
  ///
  /// In es, this message translates to:
  /// **'El plan gratuito incluye una vitrina de 360 espacios. Una vitrina adicional requiere Aura Pro o un crédito de carpeta.'**
  String get freeTierLimitMessage;

  /// No description provided for @notNowButton.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get notNowButton;

  /// No description provided for @viewAuraProButton.
  ///
  /// In es, this message translates to:
  /// **'Ver opciones Aura Pro'**
  String get viewAuraProButton;

  /// No description provided for @occupiedCount.
  ///
  /// In es, this message translates to:
  /// **'{occupied} / {total}'**
  String occupiedCount(int occupied, int total);

  /// No description provided for @estimatedValue.
  ///
  /// In es, this message translates to:
  /// **'Valor estimado: {value}'**
  String estimatedValue(String value);

  /// No description provided for @visibilityPublic.
  ///
  /// In es, this message translates to:
  /// **'Pública'**
  String get visibilityPublic;

  /// No description provided for @visibilityPrivate.
  ///
  /// In es, this message translates to:
  /// **'Privada'**
  String get visibilityPrivate;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get loading;

  /// No description provided for @unavailableBinder.
  ///
  /// In es, this message translates to:
  /// **'Vitrina no disponible'**
  String get unavailableBinder;

  /// No description provided for @shareBinder.
  ///
  /// In es, this message translates to:
  /// **'Compartir vitrina'**
  String get shareBinder;

  /// No description provided for @shareBinderMessage.
  ///
  /// In es, this message translates to:
  /// **'Mira mi vitrina en AuraDeck: https://{url}'**
  String shareBinderMessage(String url);

  /// No description provided for @pageIndicator.
  ///
  /// In es, this message translates to:
  /// **'Página {current} / {total}'**
  String pageIndicator(int current, int total);

  /// No description provided for @jumpToPage.
  ///
  /// In es, this message translates to:
  /// **'Saltar a una página'**
  String get jumpToPage;

  /// No description provided for @pageNumber.
  ///
  /// In es, this message translates to:
  /// **'Página {number}'**
  String pageNumber(int number);

  /// No description provided for @jumpButton.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get jumpButton;

  /// No description provided for @addItemButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar pieza'**
  String get addItemButton;

  /// No description provided for @binderFullButton.
  ///
  /// In es, this message translates to:
  /// **'Vitrina llena'**
  String get binderFullButton;

  /// No description provided for @emptyBinderMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta vitrina aún está vacía. Toca un bolsillo para agregar la primera pieza.'**
  String get emptyBinderMessage;

  /// No description provided for @publicRestrictedTitle.
  ///
  /// In es, this message translates to:
  /// **'Vitrina privada o no disponible'**
  String get publicRestrictedTitle;

  /// No description provided for @publicRestrictedMessage.
  ///
  /// In es, this message translates to:
  /// **'El propietario no ha autorizado que esta vitrina sea pública.'**
  String get publicRestrictedMessage;

  /// No description provided for @foilBadge.
  ///
  /// In es, this message translates to:
  /// **'FOIL'**
  String get foilBadge;

  /// No description provided for @openItem.
  ///
  /// In es, this message translates to:
  /// **'Abrir {name}'**
  String openItem(String name);

  /// No description provided for @itemUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Artículo no disponible'**
  String get itemUnavailable;

  /// No description provided for @conditionValue.
  ///
  /// In es, this message translates to:
  /// **'Condición: {value}'**
  String conditionValue(String value);

  /// No description provided for @priceValue.
  ///
  /// In es, this message translates to:
  /// **'Precio: {value}'**
  String priceValue(String value);

  /// No description provided for @sourceTcgdex.
  ///
  /// In es, this message translates to:
  /// **'Catálogo Pokémon · TCGdex'**
  String get sourceTcgdex;

  /// No description provided for @sourceScryfall.
  ///
  /// In es, this message translates to:
  /// **'Catálogo Magic · Scryfall'**
  String get sourceScryfall;

  /// No description provided for @sourceYgoprodeck.
  ///
  /// In es, this message translates to:
  /// **'Catálogo Yu-Gi-Oh! · YGOPRODeck'**
  String get sourceYgoprodeck;

  /// No description provided for @sourceUpload.
  ///
  /// In es, this message translates to:
  /// **'Registro fotográfico'**
  String get sourceUpload;

  /// No description provided for @foilLabel.
  ///
  /// In es, this message translates to:
  /// **'Efecto foil'**
  String get foilLabel;

  /// No description provided for @foilHint.
  ///
  /// In es, this message translates to:
  /// **'Activa el reflejo holográfico y la iluminación cromática.'**
  String get foilHint;

  /// No description provided for @notesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notesLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChangesButton;

  /// No description provided for @deleteItemButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar de la vitrina'**
  String get deleteItemButton;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get saved;

  /// No description provided for @deleteItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar pieza'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres eliminar «{name}» de esta vitrina?'**
  String deleteItemMessage(String name);

  /// No description provided for @cancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteButton;

  /// No description provided for @reportItemButton.
  ///
  /// In es, this message translates to:
  /// **'Reportar artículo'**
  String get reportItemButton;

  /// No description provided for @reportReasonTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué deseas reportar este artículo?'**
  String get reportReasonTitle;

  /// No description provided for @reasonInappropriate.
  ///
  /// In es, this message translates to:
  /// **'Contenido inapropiado'**
  String get reasonInappropriate;

  /// No description provided for @reasonCopyright.
  ///
  /// In es, this message translates to:
  /// **'Infracción de derechos de autor'**
  String get reasonCopyright;

  /// No description provided for @reasonSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o engaño'**
  String get reasonSpam;

  /// No description provided for @reasonOther.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get reasonOther;

  /// No description provided for @reportSubmitted.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado para moderación.'**
  String get reportSubmitted;

  /// No description provided for @gyroscopeActive.
  ///
  /// In es, this message translates to:
  /// **'Iluminación giroscópica activa. Inclina el dispositivo.'**
  String get gyroscopeActive;

  /// No description provided for @gyroscopeFallback.
  ///
  /// In es, this message translates to:
  /// **'Vista estática. El sensor no está disponible.'**
  String get gyroscopeFallback;

  /// No description provided for @itemImageDescription.
  ///
  /// In es, this message translates to:
  /// **'Imagen de {name}'**
  String itemImageDescription(String name);

  /// No description provided for @staticViewButton.
  ///
  /// In es, this message translates to:
  /// **'Volver a vista estática'**
  String get staticViewButton;

  /// No description provided for @previewShineButton.
  ///
  /// In es, this message translates to:
  /// **'Probar brillo sin sensor'**
  String get previewShineButton;

  /// No description provided for @addToPocketTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar al bolsillo {number}'**
  String addToPocketTitle(int number);

  /// No description provided for @modeSearchLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get modeSearchLabel;

  /// No description provided for @modeScanLabel.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get modeScanLabel;

  /// No description provided for @modePhotoLabel.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get modePhotoLabel;

  /// No description provided for @lockedCollectionBadge.
  ///
  /// In es, this message translates to:
  /// **'fijo'**
  String get lockedCollectionBadge;

  /// No description provided for @noCatalogApiNotice.
  ///
  /// In es, this message translates to:
  /// **'ⓘ Aún no hay catálogo público conectado para {collection}. Registra tus piezas con foto.'**
  String noCatalogApiNotice(String collection);

  /// No description provided for @searchInCollectionHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar en {collection}…'**
  String searchInCollectionHint(String collection);

  /// No description provided for @onlyCollectionResultsNotice.
  ///
  /// In es, this message translates to:
  /// **'Solo se muestran cartas de {collection} en esta vitrina.'**
  String onlyCollectionResultsNotice(String collection);

  /// No description provided for @collectionMismatchError.
  ///
  /// In es, this message translates to:
  /// **'Esta vitrina solo admite piezas de {collection}.'**
  String collectionMismatchError(String collection);

  /// No description provided for @pocketOccupiedError.
  ///
  /// In es, this message translates to:
  /// **'Este bolsillo ya está ocupado. Elige otro espacio.'**
  String get pocketOccupiedError;

  /// No description provided for @scannerHeadline.
  ///
  /// In es, this message translates to:
  /// **'Escanear carta · {collection}'**
  String scannerHeadline(String collection);

  /// No description provided for @scannerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Captura la carta para leer su nombre y buscarla en el catálogo oficial.'**
  String get scannerSubtitle;

  /// No description provided for @ocrNoTextDetected.
  ///
  /// In es, this message translates to:
  /// **'No se detectó un título claro en la imagen. Puedes buscar por nombre o subir la foto.'**
  String get ocrNoTextDetected;

  /// No description provided for @searchCardTab.
  ///
  /// In es, this message translates to:
  /// **'Buscar carta'**
  String get searchCardTab;

  /// No description provided for @physicalObjectTab.
  ///
  /// In es, this message translates to:
  /// **'Objeto físico'**
  String get physicalObjectTab;

  /// No description provided for @searchCardLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la carta'**
  String get searchCardLabel;

  /// No description provided for @searchCardHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe para buscar en el catálogo'**
  String get searchCardHint;

  /// No description provided for @catalogOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu red y vuelve a intentarlo.'**
  String get catalogOffline;

  /// No description provided for @catalogRateLimited.
  ///
  /// In es, this message translates to:
  /// **'El catálogo alcanzó su límite temporal. Inténtalo más tarde.'**
  String get catalogRateLimited;

  /// No description provided for @catalogUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El catálogo no está disponible en este momento.'**
  String get catalogUnavailable;

  /// No description provided for @searchInstructions.
  ///
  /// In es, this message translates to:
  /// **'Busca una carta en el catálogo.'**
  String get searchInstructions;

  /// No description provided for @noResults.
  ///
  /// In es, this message translates to:
  /// **'No encontramos cartas con ese nombre.'**
  String get noResults;

  /// No description provided for @itemNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la pieza'**
  String get itemNameLabel;

  /// No description provided for @conditionLabel.
  ///
  /// In es, this message translates to:
  /// **'Condición'**
  String get conditionLabel;

  /// No description provided for @conditionNm.
  ///
  /// In es, this message translates to:
  /// **'Casi nueva (NM)'**
  String get conditionNm;

  /// No description provided for @conditionLp.
  ///
  /// In es, this message translates to:
  /// **'Ligeramente jugada (LP)'**
  String get conditionLp;

  /// No description provided for @conditionMp.
  ///
  /// In es, this message translates to:
  /// **'Moderadamente jugada (MP)'**
  String get conditionMp;

  /// No description provided for @conditionHp.
  ///
  /// In es, this message translates to:
  /// **'Muy jugada (HP)'**
  String get conditionHp;

  /// No description provided for @estimatedPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio estimado'**
  String get estimatedPriceLabel;

  /// No description provided for @imageReady.
  ///
  /// In es, this message translates to:
  /// **'Lista para comprimir a WebP'**
  String get imageReady;

  /// No description provided for @removeImageButton.
  ///
  /// In es, this message translates to:
  /// **'Quitar imagen'**
  String get removeImageButton;

  /// No description provided for @galleryButton.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get galleryButton;

  /// No description provided for @cameraButton.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get cameraButton;

  /// No description provided for @saveItemButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar pieza'**
  String get saveItemButton;

  /// No description provided for @imagePermissionError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo seleccionar la imagen. Revisa los permisos.'**
  String get imagePermissionError;

  /// No description provided for @physicalFormRequired.
  ///
  /// In es, this message translates to:
  /// **'Añade un nombre y selecciona una imagen.'**
  String get physicalFormRequired;

  /// No description provided for @imageCompressionError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos comprimir o guardar la imagen.'**
  String get imageCompressionError;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu colección. Inténtalo de nuevo.'**
  String get genericError;

  /// No description provided for @retryButton.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retryButton;

  /// No description provided for @authSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para guardar tus vitrinas y acceder desde cualquier dispositivo.'**
  String get authSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get continueWithApple;

  /// No description provided for @signInWithEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresar con Correo'**
  String get signInWithEmail;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get signInButton;

  /// No description provided for @emailPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido y tu contraseña.'**
  String get emailPasswordRequired;

  /// No description provided for @signOutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOutButton;

  /// No description provided for @freePlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Plan Gratuito'**
  String get freePlanLabel;

  /// No description provided for @proPlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Aura Pro'**
  String get proPlanLabel;

  /// No description provided for @technicalSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Ficha técnica'**
  String get technicalSheetTitle;

  /// No description provided for @expansionLabel.
  ///
  /// In es, this message translates to:
  /// **'Expansión'**
  String get expansionLabel;

  /// No description provided for @cardTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get cardTypeLabel;

  /// No description provided for @rarityLabel.
  ///
  /// In es, this message translates to:
  /// **'Rareza'**
  String get rarityLabel;

  /// No description provided for @cardNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Número'**
  String get cardNumberLabel;

  /// No description provided for @rulesTextLabel.
  ///
  /// In es, this message translates to:
  /// **'Texto de reglas / habilidades'**
  String get rulesTextLabel;

  /// No description provided for @conditionSealed.
  ///
  /// In es, this message translates to:
  /// **'Sellado (Sealed)'**
  String get conditionSealed;

  /// No description provided for @itemTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría o tipo (opcional)'**
  String get itemTypeLabel;

  /// No description provided for @itemTypeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Figura, Cómic, Carta gradeada'**
  String get itemTypeHint;

  /// No description provided for @confirmAddCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pieza'**
  String get confirmAddCardTitle;

  /// No description provided for @isFoilQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Es versión Foil / Holográfica?'**
  String get isFoilQuestion;

  /// No description provided for @webpSavingsSummary.
  ///
  /// In es, this message translates to:
  /// **'WebP optimizado: {original} → {compressed}'**
  String webpSavingsSummary(String original, String compressed);

  /// No description provided for @translateOfflineButton.
  ///
  /// In es, this message translates to:
  /// **'Traducir efecto offline'**
  String get translateOfflineButton;

  /// No description provided for @showOriginalTextButton.
  ///
  /// In es, this message translates to:
  /// **'Ver texto original'**
  String get showOriginalTextButton;

  /// No description provided for @tabSheetLabel.
  ///
  /// In es, this message translates to:
  /// **'Ficha'**
  String get tabSheetLabel;

  /// No description provided for @tabAuraAiLabel.
  ///
  /// In es, this message translates to:
  /// **'Aura AI'**
  String get tabAuraAiLabel;

  /// No description provided for @tabShowcaseLabel.
  ///
  /// In es, this message translates to:
  /// **'Mi Vitrina'**
  String get tabShowcaseLabel;

  /// No description provided for @auraAiTitle.
  ///
  /// In es, this message translates to:
  /// **'Aura AI: Combos y Mazos'**
  String get auraAiTitle;

  /// No description provided for @auraAiRemaining.
  ///
  /// In es, this message translates to:
  /// **'{remaining} / {total} hoy'**
  String auraAiRemaining(int remaining, int total);

  /// No description provided for @analyzeSynergiesButton.
  ///
  /// In es, this message translates to:
  /// **'✨ Analizar Sinergias y Combos'**
  String get analyzeSynergiesButton;

  /// No description provided for @auraAiLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Alcanzaste los 3 análisis diarios gratuitos. Mejora a Aura Pro para análisis ilimitados.'**
  String get auraAiLimitReached;

  /// No description provided for @auraAiArchetypesTitle.
  ///
  /// In es, this message translates to:
  /// **'Arquetipos recomendados'**
  String get auraAiArchetypesTitle;

  /// No description provided for @auraAiCombosTitle.
  ///
  /// In es, this message translates to:
  /// **'3 cartas con sinergia clave'**
  String get auraAiCombosTitle;

  /// No description provided for @auraAiTacticalTipTitle.
  ///
  /// In es, this message translates to:
  /// **'Consejo táctico'**
  String get auraAiTacticalTipTitle;

  /// No description provided for @addToDeckButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar a un Mazo'**
  String get addToDeckButton;

  /// No description provided for @deckBuilderComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Constructor de Mazos disponible en la siguiente actualización.'**
  String get deckBuilderComingSoon;

  /// No description provided for @scannerCameraFallback.
  ///
  /// In es, this message translates to:
  /// **'Cámara no disponible en este dispositivo. Usa la galería para probar el escáner.'**
  String get scannerCameraFallback;

  /// No description provided for @scannerGuideHint.
  ///
  /// In es, this message translates to:
  /// **'Encuadra el nombre y arte de la carta dentro del marco dorado.'**
  String get scannerGuideHint;

  /// No description provided for @captureCardButton.
  ///
  /// In es, this message translates to:
  /// **'Capturar y buscar'**
  String get captureCardButton;

  /// No description provided for @openScannerCameraButton.
  ///
  /// In es, this message translates to:
  /// **'Abrir cámara escáner'**
  String get openScannerCameraButton;

  /// No description provided for @publicPreviewButton.
  ///
  /// In es, this message translates to:
  /// **'Vista Previa Pública'**
  String get publicPreviewButton;

  /// No description provided for @valuationPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de Valorización'**
  String get valuationPanelTitle;

  /// No description provided for @totalPiecesLabel.
  ///
  /// In es, this message translates to:
  /// **'Piezas registradas'**
  String get totalPiecesLabel;

  /// No description provided for @totalValuationLabel.
  ///
  /// In es, this message translates to:
  /// **'Valor total estimado'**
  String get totalValuationLabel;

  /// No description provided for @spaceStoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienda de Espacios'**
  String get spaceStoreTitle;

  /// No description provided for @binderCreditsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} créditos'**
  String binderCreditsCount(int count);

  /// No description provided for @buyExtraBinderButton.
  ///
  /// In es, this message translates to:
  /// **'Adquirir Carpeta Extra (360 espacios)'**
  String get buyExtraBinderButton;

  /// No description provided for @upgradeToProButton.
  ///
  /// In es, this message translates to:
  /// **'Mejorar a Aura Pro'**
  String get upgradeToProButton;

  /// No description provided for @purchaseCompletedMessage.
  ///
  /// In es, this message translates to:
  /// **'Compra simulada aplicada a tu cuenta.'**
  String get purchaseCompletedMessage;

  /// No description provided for @adminModeLabel.
  ///
  /// In es, this message translates to:
  /// **'Modo auditoría Admin'**
  String get adminModeLabel;

  /// No description provided for @moderationPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de Moderación'**
  String get moderationPanelTitle;

  /// No description provided for @moderationEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes pendientes de revisión.'**
  String get moderationEmptyMessage;

  /// No description provided for @dismissReportButton.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get dismissReportButton;

  /// No description provided for @markReviewedButton.
  ///
  /// In es, this message translates to:
  /// **'Marcar revisado'**
  String get markReviewedButton;

  /// No description provided for @countryCurrencyTitle.
  ///
  /// In es, this message translates to:
  /// **'País y moneda'**
  String get countryCurrencyTitle;

  /// No description provided for @countryLabel.
  ///
  /// In es, this message translates to:
  /// **'País'**
  String get countryLabel;

  /// No description provided for @selectCountryPrompt.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu país'**
  String get selectCountryPrompt;

  /// No description provided for @currencyLabel.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currencyLabel;

  /// No description provided for @searchCountryHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar país...'**
  String get searchCountryHint;

  /// No description provided for @searchCurrencyHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar moneda (ej. USD, CLP, EUR)...'**
  String get searchCurrencyHint;

  /// No description provided for @currencyAutoUpdatedHint.
  ///
  /// In es, this message translates to:
  /// **'Al elegir tu país se asigna su moneda por defecto, pero puedes cambiarla a USD, CLP o la que prefieras.'**
  String get currencyAutoUpdatedHint;

  /// No description provided for @spaceBankTitle.
  ///
  /// In es, this message translates to:
  /// **'Banco de Espacios'**
  String get spaceBankTitle;

  /// No description provided for @allocatedSlotsLabel.
  ///
  /// In es, this message translates to:
  /// **'En uso en vitrinas'**
  String get allocatedSlotsLabel;

  /// No description provided for @availableSlotsLabel.
  ///
  /// In es, this message translates to:
  /// **'Espacios disponibles'**
  String get availableSlotsLabel;

  /// No description provided for @spaceBankHint.
  ///
  /// In es, this message translates to:
  /// **'Tú decides en qué carpeta usar tus espacios disponibles.'**
  String get spaceBankHint;

  /// No description provided for @buySingleSheetButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar +1 Hoja (9 espacios)'**
  String get buySingleSheetButton;

  /// No description provided for @buyTenSheetsButton.
  ///
  /// In es, this message translates to:
  /// **'Pack +10 Hojas (90 espacios)'**
  String get buyTenSheetsButton;

  /// No description provided for @upgradeToProAnnualButton.
  ///
  /// In es, this message translates to:
  /// **'Aura Pro Anual (Ilimitado)'**
  String get upgradeToProAnnualButton;

  /// No description provided for @remainingSlotsBanner.
  ///
  /// In es, this message translates to:
  /// **'Te quedan {count} espacios disponibles'**
  String remainingSlotsBanner(int count);

  /// No description provided for @collectionCompleteBadge.
  ///
  /// In es, this message translates to:
  /// **'Colección Completa'**
  String get collectionCompleteBadge;

  /// No description provided for @completeCollectionButton.
  ///
  /// In es, this message translates to:
  /// **'¿Colección completa?'**
  String get completeCollectionButton;

  /// No description provided for @completeCollectionConfirm.
  ///
  /// In es, this message translates to:
  /// **'Esta vitrina se ajustará a sus {used} espacios ocupados y los {released} espacios sobrantes volverán a tu Banco de Espacios.'**
  String completeCollectionConfirm(int used, int released);

  /// No description provided for @yesCompleteButton.
  ///
  /// In es, this message translates to:
  /// **'Sí, completar'**
  String get yesCompleteButton;

  /// No description provided for @editBinderTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar vitrina'**
  String get editBinderTitle;

  /// No description provided for @manageSpacesTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar espacios (máx. 900)'**
  String get manageSpacesTitle;

  /// No description provided for @addSheetFromBankButton.
  ///
  /// In es, this message translates to:
  /// **'+1 Hoja (+9)'**
  String get addSheetFromBankButton;

  /// No description provided for @releaseEmptySheetButton.
  ///
  /// In es, this message translates to:
  /// **'-1 Hoja (-9)'**
  String get releaseEmptySheetButton;

  /// No description provided for @deleteBinderButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar vitrina'**
  String get deleteBinderButton;

  /// No description provided for @deleteBinderConfirm.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{title}\" y todos sus {slots} espacios volverán a tu Banco de Espacios.'**
  String deleteBinderConfirm(String title, int slots);

  /// No description provided for @notEnoughBankSpaces.
  ///
  /// In es, this message translates to:
  /// **'No tienes suficientes espacios en tu Banco. Adquiere hojas en Ajustes.'**
  String get notEnoughBankSpaces;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
