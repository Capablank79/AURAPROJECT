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
  String get selectLanguage => 'CHOOSE YOUR LANGUAGE';

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
  String get continueButton => 'Continue';

  @override
  String get backButton => 'Back';

  @override
  String get chooseCollectionTitle => 'What will you collect?';

  @override
  String get chooseCollectionSubtitle =>
      'Choose a collection to prepare your first free showcase.';

  @override
  String get chooseFamilySubtitle =>
      'Pick a family first. You can create more showcases later.';

  @override
  String get familyCardsTitle => 'Trading cards';

  @override
  String get familyCardsSubtitle =>
      'Magic, Pokémon, Yu-Gi-Oh!, One Piece, Lorcana, Naruto, and any card game.';

  @override
  String get familyObjectsTitle => 'Object collection';

  @override
  String get familyObjectsSubtitle =>
      'Figures, comics, retro video games, statues, and physical items.';

  @override
  String get chooseCardGameTitle => 'Which card game?';

  @override
  String get chooseCardGameSubtitle =>
      'Catalog search and card scanning activate automatically when an official API is available.';

  @override
  String get chooseObjectTypeTitle => 'Which type of objects?';

  @override
  String get chooseObjectTypeSubtitle =>
      'Register your pieces with optimized WebP photography.';

  @override
  String get selectCardGameLabel => 'Card game';

  @override
  String get selectObjectTypeLabel => 'Collection type';

  @override
  String get filterGamesHint => 'Find game…';

  @override
  String get gameMagic => 'Magic: The Gathering';

  @override
  String get gamePokemon => 'Pokémon TCG';

  @override
  String get gameYugioh => 'Yu-Gi-Oh!';

  @override
  String get gameOnePiece => 'One Piece Card Game';

  @override
  String get gameLorcana => 'Disney Lorcana';

  @override
  String get gameDigimon => 'Digimon Card Game';

  @override
  String get gameDragonBall => 'Dragon Ball Super Card Game';

  @override
  String get gameStarWars => 'Star Wars: Unlimited';

  @override
  String get gameFleshAndBlood => 'Flesh and Blood';

  @override
  String get gameNaruto => 'Naruto (Kayou / CCG)';

  @override
  String get gameOtherCard => 'Other card game…';

  @override
  String get objectFigures => 'Figures & statues';

  @override
  String get objectComics => 'Comics & manga';

  @override
  String get objectRetroGames => 'Retro games & consoles';

  @override
  String get objectOther => 'Other collection…';

  @override
  String get customCollectionNameLabel => 'Collection name';

  @override
  String get customCollectionNameHint => 'e.g. Sports cards, regional TCG…';

  @override
  String get capabilitySearchBadge => 'Search';

  @override
  String get capabilityScannerBadge => 'Scanner';

  @override
  String get capabilityManualOnlyBadge => 'Manual only';

  @override
  String get nameYourShowcaseTitle => 'Name your showcase';

  @override
  String get changeSelectionButton => 'Change';

  @override
  String get showcaseIncludesTitle => 'THIS SHOWCASE INCLUDES';

  @override
  String includesCatalogSearch(String collection) {
    return 'Official $collection catalog search';
  }

  @override
  String get includesCameraScanner =>
      'Camera card scanner with on-device reading';

  @override
  String get includesManualWebp =>
      'Optimized WebP photo capture + local title reading';

  @override
  String includesSingleCollectionRule(String collection) {
    return 'Exclusive to $collection items (no mixing)';
  }

  @override
  String namedCollectionSuggestion(String collection) {
    return 'My $collection showcase';
  }

  @override
  String get firstBinderNameLabel => 'Showcase name';

  @override
  String get firstBinderNameHint => 'e.g. My favorite Commanders';

  @override
  String get pokemonBinderSuggestion => 'My Pokémon collection';

  @override
  String get magicBinderSuggestion => 'My favorite Commanders';

  @override
  String get customBinderSuggestion => 'My personal showcase';

  @override
  String get createFreeBinderButton => 'Create my free showcase';

  @override
  String get freeBinderCapacityHint => '360 slots · 3×3 grid · free';

  @override
  String get categoryPokemonDescription => 'Pokémon TCG cards and expansions.';

  @override
  String get categoryMagicDescription => 'Magic: The Gathering cards and sets.';

  @override
  String get categoryCustomDescription =>
      'Figures, comics, video games, retro items, and more.';

  @override
  String selectCategorySemantic(String category) {
    return 'Select $category';
  }

  @override
  String get auraLogoDescription => 'AuraDeck golden sigil and chromatic halo';

  @override
  String get navShowcases => 'My showcases';

  @override
  String get navSearchCollection => 'Search my showcases';

  @override
  String get navSettings => 'Settings';

  @override
  String get auraProBannerTitle => 'Aura Pro';

  @override
  String get auraProBannerSubtitle =>
      'Unlimited showcases and Master Set XL format';

  @override
  String get searchMyShowcasesLabel => 'Search your showcases';

  @override
  String get searchMyShowcasesHint =>
      'Filter by stored card or collectible name';

  @override
  String get noStoredItemsFound => 'No stored items match yet.';

  @override
  String get yourCollection => 'Your showcases';

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
  String get addBinderButton => 'New showcase';

  @override
  String get chooseFirstCollectionButton => 'Choose my first collection';

  @override
  String get emptyCollectionTitle => 'Your showcase starts here';

  @override
  String get emptyCollectionMessage =>
      'Choose what to collect and create your first 360-slot showcase for free.';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get createBinderTitle => 'Create a new showcase';

  @override
  String get binderTitleLabel => 'Showcase name';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryPokemon => 'Pokémon';

  @override
  String get categoryMagic => 'Magic';

  @override
  String get categoryCustom => 'Physical objects';

  @override
  String get publicBinderLabel => 'Public showcase';

  @override
  String get publicBinderHint =>
      'Allow read-only viewing through a shared link.';

  @override
  String get createButton => 'Create showcase';

  @override
  String get createBinderError =>
      'Could not create the showcase. Check the details and try again.';

  @override
  String get freeTierLimitTitle => 'Your free showcase is already in use';

  @override
  String get freeTierLimitMessage =>
      'The free plan includes one 360-slot showcase. An additional showcase requires Aura Pro or a binder credit.';

  @override
  String get notNowButton => 'Not now';

  @override
  String get viewAuraProButton => 'View Aura Pro options';

  @override
  String occupiedCount(int occupied, int total) {
    return '$occupied / $total';
  }

  @override
  String estimatedValue(String value) {
    return 'Estimated value: $value';
  }

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get loading => 'Loading';

  @override
  String get unavailableBinder => 'Showcase unavailable';

  @override
  String get shareBinder => 'Share showcase';

  @override
  String shareBinderMessage(String url) {
    return 'View my AuraDeck showcase: https://$url';
  }

  @override
  String pageIndicator(int current, int total) {
    return 'Page $current / $total';
  }

  @override
  String get jumpToPage => 'Jump to a page';

  @override
  String pageNumber(int number) {
    return 'Page $number';
  }

  @override
  String get jumpButton => 'Jump';

  @override
  String get addItemButton => 'Add item';

  @override
  String get binderFullButton => 'Showcase full';

  @override
  String get emptyBinderMessage =>
      'This showcase is empty. Tap a pocket to add your first item.';

  @override
  String get publicRestrictedTitle => 'Private or unavailable showcase';

  @override
  String get publicRestrictedMessage =>
      'The owner has not made this showcase public.';

  @override
  String get foilBadge => 'FOIL';

  @override
  String openItem(String name) {
    return 'Open $name';
  }

  @override
  String get itemUnavailable => 'Item unavailable';

  @override
  String conditionValue(String value) {
    return 'Condition: $value';
  }

  @override
  String priceValue(String value) {
    return 'Price: $value';
  }

  @override
  String get sourceTcgdex => 'Pokémon catalog · TCGdex';

  @override
  String get sourceScryfall => 'Magic catalog · Scryfall';

  @override
  String get sourceYgoprodeck => 'Yu-Gi-Oh! catalog · YGOPRODeck';

  @override
  String get sourceUpload => 'Photo entry';

  @override
  String get foilLabel => 'Foil effect';

  @override
  String get foilHint =>
      'Enable the holographic reflection and chromatic lighting.';

  @override
  String get notesLabel => 'Notes';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get deleteItemButton => 'Remove from showcase';

  @override
  String get saved => 'Changes saved';

  @override
  String get deleteItemTitle => 'Remove item';

  @override
  String deleteItemMessage(String name) {
    return 'Remove «$name» from this showcase?';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Remove';

  @override
  String get reportItemButton => 'Report item';

  @override
  String get reportReasonTitle => 'Why are you reporting this item?';

  @override
  String get reasonInappropriate => 'Inappropriate content';

  @override
  String get reasonCopyright => 'Copyright infringement';

  @override
  String get reasonSpam => 'Spam or deception';

  @override
  String get reasonOther => 'Other reason';

  @override
  String get reportSubmitted => 'Report submitted for moderation.';

  @override
  String get gyroscopeActive => 'Gyroscopic lighting active. Tilt your device.';

  @override
  String get gyroscopeFallback => 'Static view. No sensor is available.';

  @override
  String itemImageDescription(String name) {
    return 'Image of $name';
  }

  @override
  String get staticViewButton => 'Return to static view';

  @override
  String get previewShineButton => 'Preview shine without a sensor';

  @override
  String addToPocketTitle(int number) {
    return 'Add to pocket $number';
  }

  @override
  String get modeSearchLabel => 'Search';

  @override
  String get modeScanLabel => 'Scan';

  @override
  String get modePhotoLabel => 'Photo';

  @override
  String get lockedCollectionBadge => 'locked';

  @override
  String noCatalogApiNotice(String collection) {
    return 'ⓘ No public catalog is connected for $collection yet. Add your items by photo.';
  }

  @override
  String searchInCollectionHint(String collection) {
    return 'Search $collection…';
  }

  @override
  String onlyCollectionResultsNotice(String collection) {
    return 'Only $collection cards are shown in this showcase.';
  }

  @override
  String collectionMismatchError(String collection) {
    return 'This showcase only accepts $collection items.';
  }

  @override
  String get pocketOccupiedError =>
      'This pocket is already occupied. Choose another slot.';

  @override
  String scannerHeadline(String collection) {
    return 'Scan card · $collection';
  }

  @override
  String get scannerSubtitle =>
      'Capture the card to read its title and look it up in the official catalog.';

  @override
  String get ocrNoTextDetected =>
      'No clear title was detected. You can search by name or upload the photo.';

  @override
  String get searchCardTab => 'Find card';

  @override
  String get physicalObjectTab => 'Physical object';

  @override
  String get searchCardLabel => 'Card name';

  @override
  String get searchCardHint => 'Type to search the catalog';

  @override
  String get catalogOffline => 'Offline. Check your network and try again.';

  @override
  String get catalogRateLimited =>
      'The catalog reached its temporary limit. Try again later.';

  @override
  String get catalogUnavailable => 'The catalog is currently unavailable.';

  @override
  String get searchInstructions => 'Search for a card in the catalog.';

  @override
  String get noResults => 'No cards found with that name.';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get conditionNm => 'Near mint (NM)';

  @override
  String get conditionLp => 'Lightly played (LP)';

  @override
  String get conditionMp => 'Moderately played (MP)';

  @override
  String get conditionHp => 'Heavily played (HP)';

  @override
  String get estimatedPriceLabel => 'Estimated price';

  @override
  String get imageReady => 'Ready to compress as WebP';

  @override
  String get removeImageButton => 'Remove image';

  @override
  String get galleryButton => 'Gallery';

  @override
  String get cameraButton => 'Camera';

  @override
  String get saveItemButton => 'Save item';

  @override
  String get imagePermissionError =>
      'The image could not be selected. Check permissions.';

  @override
  String get physicalFormRequired => 'Add a name and select an image.';

  @override
  String get imageCompressionError =>
      'We could not compress or store the image.';

  @override
  String get genericError =>
      'We could not load your collection. Please try again.';

  @override
  String get retryButton => 'Retry';

  @override
  String get authSubtitle =>
      'Sign in to save your showcases and access them from any device.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get emailPasswordRequired =>
      'Enter a valid email address and password.';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get freePlanLabel => 'Free Plan';

  @override
  String get proPlanLabel => 'Aura Pro';

  @override
  String get technicalSheetTitle => 'Technical sheet';

  @override
  String get expansionLabel => 'Expansion';

  @override
  String get cardTypeLabel => 'Type';

  @override
  String get rarityLabel => 'Rarity';

  @override
  String get cardNumberLabel => 'Number';

  @override
  String get rulesTextLabel => 'Rules / abilities text';

  @override
  String get conditionSealed => 'Sealed';

  @override
  String get itemTypeLabel => 'Category or type (optional)';

  @override
  String get itemTypeHint => 'e.g. Figure, Comic, Graded card';

  @override
  String get confirmAddCardTitle => 'Confirm item';

  @override
  String get isFoilQuestion => 'Foil / Holographic version?';

  @override
  String webpSavingsSummary(String original, String compressed) {
    return 'Optimized WebP: $original → $compressed';
  }

  @override
  String get translateOfflineButton => 'Translate effect offline';

  @override
  String get showOriginalTextButton => 'Show original text';

  @override
  String get tabSheetLabel => 'Details';

  @override
  String get tabAuraAiLabel => 'Aura AI';

  @override
  String get tabShowcaseLabel => 'My Showcase';

  @override
  String get auraAiTitle => 'Aura AI: Combos & Decks';

  @override
  String auraAiRemaining(int remaining, int total) {
    return '$remaining / $total today';
  }

  @override
  String get analyzeSynergiesButton => '✨ Analyze Synergies & Combos';

  @override
  String get auraAiLimitReached =>
      'You reached the 3 daily free analyses. Upgrade to Aura Pro for unlimited insights.';

  @override
  String get auraAiArchetypesTitle => 'Recommended archetypes';

  @override
  String get auraAiCombosTitle => '3 key synergy cards';

  @override
  String get auraAiTacticalTipTitle => 'Tactical tip';

  @override
  String get addToDeckButton => 'Add to a Deck';

  @override
  String get deckBuilderComingSoon =>
      'Deckbuilder will be available in the next update.';

  @override
  String get scannerCameraFallback =>
      'Camera unavailable on this device. Use Gallery to test the scanner.';

  @override
  String get scannerGuideHint =>
      'Align the card title and artwork inside the golden frame.';

  @override
  String get captureCardButton => 'Capture & search';

  @override
  String get openScannerCameraButton => 'Open scanner camera';

  @override
  String get publicPreviewButton => 'Public Preview';

  @override
  String get valuationPanelTitle => 'Portfolio Valuation';

  @override
  String get totalPiecesLabel => 'Registered items';

  @override
  String get totalValuationLabel => 'Estimated total value';

  @override
  String get spaceStoreTitle => 'Space Store';

  @override
  String binderCreditsCount(int count) {
    return '$count credits';
  }

  @override
  String get buyExtraBinderButton => 'Get Extra Binder (360 slots)';

  @override
  String get upgradeToProButton => 'Upgrade to Aura Pro';

  @override
  String get purchaseCompletedMessage =>
      'Simulated purchase applied to your account.';

  @override
  String get adminModeLabel => 'Admin audit mode';

  @override
  String get moderationPanelTitle => 'Moderation Panel';

  @override
  String get moderationEmptyMessage => 'No reports pending review.';

  @override
  String get dismissReportButton => 'Dismiss';

  @override
  String get markReviewedButton => 'Mark reviewed';

  @override
  String get countryCurrencyTitle => 'Country & Currency';

  @override
  String get countryLabel => 'Country';

  @override
  String get selectCountryPrompt => 'Select your country';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get searchCountryHint => 'Search country...';

  @override
  String get searchCurrencyHint => 'Search currency (e.g. USD, CLP, EUR)...';

  @override
  String get currencyAutoUpdatedHint =>
      'Picking your country sets its default currency, and you can switch to USD, CLP, or any currency anytime.';

  @override
  String get spaceBankTitle => 'Space Bank';

  @override
  String get allocatedSlotsLabel => 'In active showcases';

  @override
  String get availableSlotsLabel => 'Available spaces';

  @override
  String get spaceBankHint =>
      'You choose which showcase to assign your available spaces to.';

  @override
  String get buySingleSheetButton => 'Add +1 Sheet (9 spaces)';

  @override
  String get buyTenSheetsButton => 'Pack +10 Sheets (90 spaces)';

  @override
  String get upgradeToProAnnualButton => 'Aura Pro Annual (Unlimited)';

  @override
  String remainingSlotsBanner(int count) {
    return '$count spaces remaining';
  }

  @override
  String get collectionCompleteBadge => 'Complete Collection';

  @override
  String get completeCollectionButton => 'Collection complete?';

  @override
  String completeCollectionConfirm(int used, int released) {
    return 'This showcase will resize to its $used occupied spaces and the remaining $released spaces will return to your Space Bank.';
  }

  @override
  String get yesCompleteButton => 'Yes, complete';

  @override
  String get editBinderTitle => 'Edit showcase';

  @override
  String get manageSpacesTitle => 'Manage spaces (max 900)';

  @override
  String get addSheetFromBankButton => '+1 Sheet (+9)';

  @override
  String get releaseEmptySheetButton => '-1 Sheet (-9)';

  @override
  String get deleteBinderButton => 'Delete showcase';

  @override
  String deleteBinderConfirm(String title, int slots) {
    return '\"$title\" will be deleted and all $slots spaces will return to your Space Bank.';
  }

  @override
  String get notEnoughBankSpaces =>
      'Not enough spaces in your Space Bank. Get sheets in Settings.';
}
