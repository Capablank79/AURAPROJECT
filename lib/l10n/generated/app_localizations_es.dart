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
  String get selectLanguage => 'ELIGE TU IDIOMA';

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
  String get continueButton => 'Continuar';

  @override
  String get backButton => 'Volver';

  @override
  String get chooseCollectionTitle => '¿Qué vas a coleccionar?';

  @override
  String get chooseCollectionSubtitle =>
      'Elige una colección para preparar tu primera vitrina gratuita.';

  @override
  String get chooseFamilySubtitle =>
      'Elige primero la familia. Podrás crear más vitrinas después.';

  @override
  String get familyCardsTitle => 'Cartas coleccionables';

  @override
  String get familyCardsSubtitle =>
      'Magic, Pokémon, Yu-Gi-Oh!, One Piece, Lorcana, Naruto y cualquier juego de cartas.';

  @override
  String get familyObjectsTitle => 'Colección de objetos';

  @override
  String get familyObjectsSubtitle =>
      'Figuras, cómics, videojuegos retro, estatuas y piezas físicas.';

  @override
  String get chooseCardGameTitle => '¿Qué juego de cartas?';

  @override
  String get chooseCardGameSubtitle =>
      'La búsqueda y el escáner se activan automáticamente en los juegos con catálogo disponible.';

  @override
  String get chooseObjectTypeTitle => '¿Qué tipo de objetos?';

  @override
  String get chooseObjectTypeSubtitle =>
      'Registra tus piezas con fotografía optimizada en formato WebP.';

  @override
  String get selectCardGameLabel => 'Juego de cartas';

  @override
  String get selectObjectTypeLabel => 'Tipo de colección';

  @override
  String get filterGamesHint => 'Buscar juego…';

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
  String get gameOtherCard => 'Otro juego de cartas…';

  @override
  String get objectFigures => 'Figuras y estatuas';

  @override
  String get objectComics => 'Cómics y manga';

  @override
  String get objectRetroGames => 'Videojuegos y consolas';

  @override
  String get objectOther => 'Otro tipo de colección…';

  @override
  String get customCollectionNameLabel => 'Nombre de la colección';

  @override
  String get customCollectionNameHint =>
      'Ej. Mitos y Leyendas, cartas deportivas…';

  @override
  String get capabilitySearchBadge => 'Búsqueda';

  @override
  String get capabilityScannerBadge => 'Escáner';

  @override
  String get capabilityManualOnlyBadge => 'Solo manual';

  @override
  String get nameYourShowcaseTitle => 'Dale nombre a tu vitrina';

  @override
  String get changeSelectionButton => 'Cambiar';

  @override
  String get showcaseIncludesTitle => 'ESTA VITRINA INCLUYE';

  @override
  String includesCatalogSearch(String collection) {
    return 'Búsqueda en catálogo oficial de $collection';
  }

  @override
  String get includesCameraScanner =>
      'Escáner de cartas con cámara y lectura local';

  @override
  String get includesManualWebp =>
      'Registro fotográfico optimizado WebP + lectura local de título';

  @override
  String includesSingleCollectionRule(String collection) {
    return ' Exclusiva para piezas de $collection (sin mezclas)';
  }

  @override
  String namedCollectionSuggestion(String collection) {
    return 'Mi vitrina de $collection';
  }

  @override
  String get firstBinderNameLabel => 'Nombre de tu vitrina';

  @override
  String get firstBinderNameHint => 'Ej. Mis Commanders favoritos';

  @override
  String get pokemonBinderSuggestion => 'Mi colección Pokémon';

  @override
  String get magicBinderSuggestion => 'Mis Commanders favoritos';

  @override
  String get customBinderSuggestion => 'Mi vitrina personal';

  @override
  String get createFreeBinderButton => 'Crear mi vitrina gratis';

  @override
  String get freeBinderCapacityHint => '360 espacios · cuadrícula 3×3 · gratis';

  @override
  String get categoryPokemonDescription =>
      'Cartas y expansiones de Pokémon TCG.';

  @override
  String get categoryMagicDescription =>
      'Cartas y ediciones de Magic: The Gathering.';

  @override
  String get categoryCustomDescription =>
      'Figuras, cómics, videojuegos, piezas retro y más.';

  @override
  String selectCategorySemantic(String category) {
    return 'Seleccionar $category';
  }

  @override
  String get auraLogoDescription =>
      'Isotipo dorado y halo cromático de AuraDeck';

  @override
  String get navShowcases => 'Mis vitrinas';

  @override
  String get navSearchCollection => 'Buscar en mis vitrinas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get auraProBannerTitle => 'Aura Pro';

  @override
  String get auraProBannerSubtitle =>
      'Vitrinas ilimitadas y formato Master Set XL';

  @override
  String get searchMyShowcasesLabel => 'Buscar en tus vitrinas';

  @override
  String get searchMyShowcasesHint =>
      'Filtra por nombre de carta u objeto guardado';

  @override
  String get noStoredItemsFound => 'Aún no hay piezas guardadas que coincidan.';

  @override
  String get yourCollection => 'Tus vitrinas';

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
  String get addBinderButton => 'Nueva vitrina';

  @override
  String get chooseFirstCollectionButton => 'Elegir mi primera colección';

  @override
  String get emptyCollectionTitle => 'Tu vitrina comienza aquí';

  @override
  String get emptyCollectionMessage =>
      'Elige qué coleccionar y crea gratis tu primera vitrina de 360 espacios.';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get createBinderTitle => 'Crear nueva vitrina';

  @override
  String get binderTitleLabel => 'Nombre de la vitrina';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryPokemon => 'Pokémon';

  @override
  String get categoryMagic => 'Magic';

  @override
  String get categoryCustom => 'Objetos físicos';

  @override
  String get publicBinderLabel => 'Vitrina pública';

  @override
  String get publicBinderHint =>
      'Permite verla mediante un enlace de solo lectura.';

  @override
  String get createButton => 'Crear vitrina';

  @override
  String get createBinderError =>
      'No pudimos crear la vitrina. Revisa los datos e inténtalo de nuevo.';

  @override
  String get freeTierLimitTitle => 'Tu vitrina gratuita ya está en uso';

  @override
  String get freeTierLimitMessage =>
      'El plan gratuito incluye una vitrina de 360 espacios. Una vitrina adicional requiere Aura Pro o un crédito de carpeta.';

  @override
  String get notNowButton => 'Ahora no';

  @override
  String get viewAuraProButton => 'Ver opciones Aura Pro';

  @override
  String occupiedCount(int occupied, int total) {
    return '$occupied / $total';
  }

  @override
  String estimatedValue(String value) {
    return 'Valor estimado: $value';
  }

  @override
  String get visibilityPublic => 'Pública';

  @override
  String get visibilityPrivate => 'Privada';

  @override
  String get loading => 'Cargando';

  @override
  String get unavailableBinder => 'Vitrina no disponible';

  @override
  String get shareBinder => 'Compartir vitrina';

  @override
  String shareBinderMessage(String url) {
    return 'Mira mi vitrina en AuraDeck: https://$url';
  }

  @override
  String pageIndicator(int current, int total) {
    return 'Página $current / $total';
  }

  @override
  String get jumpToPage => 'Saltar a una página';

  @override
  String pageNumber(int number) {
    return 'Página $number';
  }

  @override
  String get jumpButton => 'Saltar';

  @override
  String get addItemButton => 'Agregar pieza';

  @override
  String get binderFullButton => 'Vitrina llena';

  @override
  String get emptyBinderMessage =>
      'Esta vitrina aún está vacía. Toca un bolsillo para agregar la primera pieza.';

  @override
  String get publicRestrictedTitle => 'Vitrina privada o no disponible';

  @override
  String get publicRestrictedMessage =>
      'El propietario no ha autorizado que esta vitrina sea pública.';

  @override
  String get foilBadge => 'FOIL';

  @override
  String openItem(String name) {
    return 'Abrir $name';
  }

  @override
  String get itemUnavailable => 'Artículo no disponible';

  @override
  String conditionValue(String value) {
    return 'Condición: $value';
  }

  @override
  String priceValue(String value) {
    return 'Precio: $value';
  }

  @override
  String get sourceTcgdex => 'Catálogo Pokémon · TCGdex';

  @override
  String get sourceScryfall => 'Catálogo Magic · Scryfall';

  @override
  String get sourceYgoprodeck => 'Catálogo Yu-Gi-Oh! · YGOPRODeck';

  @override
  String get sourceUpload => 'Registro fotográfico';

  @override
  String get foilLabel => 'Efecto foil';

  @override
  String get foilHint =>
      'Activa el reflejo holográfico y la iluminación cromática.';

  @override
  String get notesLabel => 'Notas';

  @override
  String get saveChangesButton => 'Guardar cambios';

  @override
  String get deleteItemButton => 'Eliminar de la vitrina';

  @override
  String get saved => 'Cambios guardados';

  @override
  String get deleteItemTitle => 'Eliminar pieza';

  @override
  String deleteItemMessage(String name) {
    return '¿Quieres eliminar «$name» de esta vitrina?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get reportItemButton => 'Reportar artículo';

  @override
  String get reportReasonTitle => '¿Por qué deseas reportar este artículo?';

  @override
  String get reasonInappropriate => 'Contenido inapropiado';

  @override
  String get reasonCopyright => 'Infracción de derechos de autor';

  @override
  String get reasonSpam => 'Spam o engaño';

  @override
  String get reasonOther => 'Otro motivo';

  @override
  String get reportSubmitted => 'Reporte enviado para moderación.';

  @override
  String get gyroscopeActive =>
      'Iluminación giroscópica activa. Inclina el dispositivo.';

  @override
  String get gyroscopeFallback =>
      'Vista estática. El sensor no está disponible.';

  @override
  String itemImageDescription(String name) {
    return 'Imagen de $name';
  }

  @override
  String get staticViewButton => 'Volver a vista estática';

  @override
  String get previewShineButton => 'Probar brillo sin sensor';

  @override
  String addToPocketTitle(int number) {
    return 'Agregar al bolsillo $number';
  }

  @override
  String get modeSearchLabel => 'Buscar';

  @override
  String get modeScanLabel => 'Escanear';

  @override
  String get modePhotoLabel => 'Foto';

  @override
  String get lockedCollectionBadge => 'fijo';

  @override
  String noCatalogApiNotice(String collection) {
    return 'ⓘ Aún no hay catálogo público conectado para $collection. Registra tus piezas con foto.';
  }

  @override
  String searchInCollectionHint(String collection) {
    return 'Buscar en $collection…';
  }

  @override
  String onlyCollectionResultsNotice(String collection) {
    return 'Solo se muestran cartas de $collection en esta vitrina.';
  }

  @override
  String collectionMismatchError(String collection) {
    return 'Esta vitrina solo admite piezas de $collection.';
  }

  @override
  String get pocketOccupiedError =>
      'Este bolsillo ya está ocupado. Elige otro espacio.';

  @override
  String scannerHeadline(String collection) {
    return 'Escanear carta · $collection';
  }

  @override
  String get scannerSubtitle =>
      'Captura la carta para leer su nombre y buscarla en el catálogo oficial.';

  @override
  String get ocrNoTextDetected =>
      'No se detectó un título claro en la imagen. Puedes buscar por nombre o subir la foto.';

  @override
  String get searchCardTab => 'Buscar carta';

  @override
  String get physicalObjectTab => 'Objeto físico';

  @override
  String get searchCardLabel => 'Nombre de la carta';

  @override
  String get searchCardHint => 'Escribe para buscar en el catálogo';

  @override
  String get catalogOffline =>
      'Sin conexión. Revisa tu red y vuelve a intentarlo.';

  @override
  String get catalogRateLimited =>
      'El catálogo alcanzó su límite temporal. Inténtalo más tarde.';

  @override
  String get catalogUnavailable =>
      'El catálogo no está disponible en este momento.';

  @override
  String get searchInstructions => 'Busca una carta en el catálogo.';

  @override
  String get noResults => 'No encontramos cartas con ese nombre.';

  @override
  String get itemNameLabel => 'Nombre de la pieza';

  @override
  String get conditionLabel => 'Condición';

  @override
  String get conditionNm => 'Casi nueva (NM)';

  @override
  String get conditionLp => 'Ligeramente jugada (LP)';

  @override
  String get conditionMp => 'Moderadamente jugada (MP)';

  @override
  String get conditionHp => 'Muy jugada (HP)';

  @override
  String get estimatedPriceLabel => 'Precio estimado';

  @override
  String get imageReady => 'Lista para comprimir a WebP';

  @override
  String get removeImageButton => 'Quitar imagen';

  @override
  String get galleryButton => 'Galería';

  @override
  String get cameraButton => 'Cámara';

  @override
  String get saveItemButton => 'Guardar pieza';

  @override
  String get imagePermissionError =>
      'No se pudo seleccionar la imagen. Revisa los permisos.';

  @override
  String get physicalFormRequired => 'Añade un nombre y selecciona una imagen.';

  @override
  String get imageCompressionError =>
      'No pudimos comprimir o guardar la imagen.';

  @override
  String get genericError =>
      'No pudimos cargar tu colección. Inténtalo de nuevo.';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get authSubtitle =>
      'Inicia sesión para guardar tus vitrinas y acceder desde cualquier dispositivo.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get signInWithEmail => 'Ingresar con Correo';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get signInButton => 'Ingresar';

  @override
  String get emailPasswordRequired =>
      'Ingresa un correo válido y tu contraseña.';

  @override
  String get signOutButton => 'Cerrar sesión';

  @override
  String get freePlanLabel => 'Plan Gratuito';

  @override
  String get proPlanLabel => 'Aura Pro';

  @override
  String get technicalSheetTitle => 'Ficha técnica';

  @override
  String get expansionLabel => 'Expansión';

  @override
  String get cardTypeLabel => 'Tipo';

  @override
  String get rarityLabel => 'Rareza';

  @override
  String get cardNumberLabel => 'Número';

  @override
  String get rulesTextLabel => 'Texto de reglas / habilidades';

  @override
  String get conditionSealed => 'Sellado (Sealed)';

  @override
  String get itemTypeLabel => 'Categoría o tipo (opcional)';

  @override
  String get itemTypeHint => 'Ej. Figura, Cómic, Carta gradeada';

  @override
  String get confirmAddCardTitle => 'Confirmar pieza';

  @override
  String get isFoilQuestion => '¿Es versión Foil / Holográfica?';

  @override
  String webpSavingsSummary(String original, String compressed) {
    return 'WebP optimizado: $original → $compressed';
  }

  @override
  String get translateOfflineButton => 'Traducir efecto offline';

  @override
  String get showOriginalTextButton => 'Ver texto original';

  @override
  String get tabSheetLabel => 'Ficha';

  @override
  String get tabAuraAiLabel => 'Aura AI';

  @override
  String get tabShowcaseLabel => 'Mi Vitrina';

  @override
  String get auraAiTitle => 'Aura AI: Combos y Mazos';

  @override
  String auraAiRemaining(int remaining, int total) {
    return '$remaining / $total hoy';
  }

  @override
  String get analyzeSynergiesButton => '✨ Analizar Sinergias y Combos';

  @override
  String get auraAiLimitReached =>
      'Alcanzaste los 3 análisis diarios gratuitos. Mejora a Aura Pro para análisis ilimitados.';

  @override
  String get auraAiArchetypesTitle => 'Arquetipos recomendados';

  @override
  String get auraAiCombosTitle => '3 cartas con sinergia clave';

  @override
  String get auraAiTacticalTipTitle => 'Consejo táctico';

  @override
  String get addToDeckButton => 'Agregar a un Mazo';

  @override
  String get deckBuilderComingSoon =>
      'Constructor de Mazos disponible en la siguiente actualización.';

  @override
  String get scannerCameraFallback =>
      'Cámara no disponible en este dispositivo. Usa la galería para probar el escáner.';

  @override
  String get scannerGuideHint =>
      'Encuadra el nombre y arte de la carta dentro del marco dorado.';

  @override
  String get captureCardButton => 'Capturar y buscar';

  @override
  String get openScannerCameraButton => 'Abrir cámara escáner';

  @override
  String get publicPreviewButton => 'Vista Previa Pública';

  @override
  String get valuationPanelTitle => 'Panel de Valorización';

  @override
  String get totalPiecesLabel => 'Piezas registradas';

  @override
  String get totalValuationLabel => 'Valor total estimado';

  @override
  String get spaceStoreTitle => 'Tienda de Espacios';

  @override
  String binderCreditsCount(int count) {
    return '$count créditos';
  }

  @override
  String get buyExtraBinderButton => 'Adquirir Carpeta Extra (360 espacios)';

  @override
  String get upgradeToProButton => 'Mejorar a Aura Pro';

  @override
  String get purchaseCompletedMessage =>
      'Compra simulada aplicada a tu cuenta.';

  @override
  String get adminModeLabel => 'Modo auditoría Admin';

  @override
  String get moderationPanelTitle => 'Panel de Moderación';

  @override
  String get moderationEmptyMessage =>
      'No hay reportes pendientes de revisión.';

  @override
  String get dismissReportButton => 'Descartar';

  @override
  String get markReviewedButton => 'Marcar revisado';

  @override
  String get countryCurrencyTitle => 'País y moneda';

  @override
  String get countryLabel => 'País';

  @override
  String get selectCountryPrompt => 'Selecciona tu país';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get searchCountryHint => 'Buscar país...';

  @override
  String get searchCurrencyHint => 'Buscar moneda (ej. USD, CLP, EUR)...';

  @override
  String get currencyAutoUpdatedHint =>
      'Al elegir tu país se asigna su moneda por defecto, pero puedes cambiarla a USD, CLP o la que prefieras.';

  @override
  String get spaceBankTitle => 'Banco de Espacios';

  @override
  String get allocatedSlotsLabel => 'En uso en vitrinas';

  @override
  String get availableSlotsLabel => 'Espacios disponibles';

  @override
  String get spaceBankHint =>
      'Tú decides en qué carpeta usar tus espacios disponibles.';

  @override
  String get buySingleSheetButton => 'Agregar +1 Hoja (9 espacios)';

  @override
  String get buyTenSheetsButton => 'Pack +10 Hojas (90 espacios)';

  @override
  String get upgradeToProAnnualButton => 'Aura Pro Anual (Ilimitado)';

  @override
  String remainingSlotsBanner(int count) {
    return 'Te quedan $count espacios disponibles';
  }

  @override
  String get collectionCompleteBadge => 'Colección Completa';

  @override
  String get completeCollectionButton => '¿Colección completa?';

  @override
  String completeCollectionConfirm(int used, int released) {
    return 'Esta vitrina se ajustará a sus $used espacios ocupados y los $released espacios sobrantes volverán a tu Banco de Espacios.';
  }

  @override
  String get yesCompleteButton => 'Sí, completar';

  @override
  String get editBinderTitle => 'Editar vitrina';

  @override
  String get manageSpacesTitle => 'Gestionar espacios (máx. 900)';

  @override
  String get addSheetFromBankButton => '+1 Hoja (+9)';

  @override
  String get releaseEmptySheetButton => '-1 Hoja (-9)';

  @override
  String get deleteBinderButton => 'Eliminar vitrina';

  @override
  String deleteBinderConfirm(String title, int slots) {
    return 'Se eliminará \"$title\" y todos sus $slots espacios volverán a tu Banco de Espacios.';
  }

  @override
  String get notEnoughBankSpaces =>
      'No tienes suficientes espacios en tu Banco. Adquiere hojas en Ajustes.';

  @override
  String get navDecks => 'Mazos';

  @override
  String get apiPolicyBannerTitle => 'Política de Autenticidad Física';

  @override
  String get apiPolicyBannerBody =>
      'Esta vitrina certifica cartas escaneadas con cámara. Si agregas desde el buscador API (modo prueba/referencia), quedará marcada públicamente como «API · Sin físico».';

  @override
  String get apiConfirmWarningTitle => 'Inserción desde API sin escaneo físico';

  @override
  String get apiConfirmWarningBody =>
      'Llevará el sello público «API · SIN FÍSICO» para indicar a quien vea tu vitrina que aún no ha sido escaneada físicamente. No podrá ponerse en venta ni cambio.';

  @override
  String get apiUnverifiedBadge => 'API · SIN FÍSICO';

  @override
  String get apiReferenceWatermark => 'REFERENCIA API · NO FÍSICA';

  @override
  String get physicalVerifiedBadge => 'FÍSICA';

  @override
  String get physicalVerifiedBanner =>
      'Posesión física verificada por escáner o fotografía.';

  @override
  String get apiUnverifiedBannerTitle =>
      'Aviso público: Sin ejemplar físico verificado';

  @override
  String get apiUnverifiedBannerBody =>
      'Agregada desde buscador API como referencia. No suma al patrimonio físico ni puede ofrecerse en cambio o venta.';

  @override
  String get verifyWithScannerButton => '📷 Ya la tengo: Verificar con escáner';

  @override
  String get verifiedSuccessMessage =>
      '¡Pieza verificada como ejemplar físico escaneado!';

  @override
  String get trustBadgeFullPhysical => '🛡️ 100% Física Escaneada';

  @override
  String trustBadgeHasApi(int count) {
    return '☁️ $count vía API sin verificar';
  }

  @override
  String get filterAll => 'Todas';

  @override
  String get filterPhysicalOnly => '📸 Solo Físicas';

  @override
  String get filterForTrade => '🔄 Cambio';

  @override
  String get filterForSale => '💲 Venta';

  @override
  String get tradeStatusLabel => 'Estado comercial (Tradelist)';

  @override
  String get tradeStatusNone => 'Solo colección';

  @override
  String get tradeStatusForTrade => 'Disponible para cambio';

  @override
  String get tradeStatusForSale => 'En venta';

  @override
  String get tradeStatusWishlistApi => 'Referencia API (Sin físico)';

  @override
  String get tradeBadgeShort => 'CAMBIO';

  @override
  String get saleBadgeShort => 'VENTA';

  @override
  String get apiCannotTradeMessage =>
      'Las referencias API sin escanear no pueden ponerse en venta ni cambio.';

  @override
  String get slabGraderLabel => 'Certificadora (Slab)';

  @override
  String get slabNoneOption => 'Sin gradear (Raw)';

  @override
  String get slabScoreLabel => 'Nota';

  @override
  String get slabCertLabel => 'N.º Cert.';

  @override
  String get purchaseCostLabel => 'Costo de compra';

  @override
  String get roiLabel => 'Plusvalía (ROI)';

  @override
  String get slabsCountLabel => 'Slabs certificados';

  @override
  String get tradelistCountLabel => 'En Tradelist';

  @override
  String get apiReferencesCountLabel => 'Referencias API (no físicas)';

  @override
  String get gridFormatLabel => 'Formato de cuadrícula';

  @override
  String get grid2x2Option => '2×2 Compacta (4 por hoja)';

  @override
  String get grid3x3Option => '3×3 Estándar (9 por hoja)';

  @override
  String get grid4x3ProOption => '4×3 Master XL (12 por hoja · Pro)';

  @override
  String get gridProRequiredMessage =>
      'El formato panorámico 4×3 (12 por hoja) requiere Aura Pro.';

  @override
  String pocketRangeIndicator(int start, int end) {
    return 'Bolsillos #$start – #$end';
  }

  @override
  String get dragSwapHint =>
      'Mantén presionada una pieza para arrastrarla a otro bolsillo';

  @override
  String get positionsSwappedMessage => 'Posiciones actualizadas en la hoja.';

  @override
  String get qrPosterButton => 'Póster QR Torneo';

  @override
  String get qrPosterTitle => 'Tarjeta QR de Vitrina';

  @override
  String get qrPosterTopGems => 'TOP PIEZAS FÍSICAS VERIFICADAS';

  @override
  String get shareQrLinkButton => 'Compartir enlace QR';

  @override
  String get batchScannerButton => 'Escáner por lote (Ráfaga)';

  @override
  String get batchScannerTitle => 'Bandeja de Escaneo por Lote';

  @override
  String get batchScannerHint =>
      'Captura varias cartas seguidas con ML Kit e insértalas juntas en bolsillos libres.';

  @override
  String get batchScanNextButton => 'Capturar siguiente carta';

  @override
  String get batchGalleryButton => 'Añadir foto desde galería';

  @override
  String get batchEmptyMessage => 'Aún no hay cartas en la bandeja de lote.';

  @override
  String batchCommitButton(int count) {
    return 'Insertar lote ($count)';
  }

  @override
  String batchCommittedMessage(int count) {
    return 'Se insertaron $count piezas físicas en bolsillos consecutivos.';
  }

  @override
  String get decksTitle => 'Constructor de Mazos';

  @override
  String get decksSubtitle =>
      'Cruza tus listas con tus vitrinas físicas verificadas.';

  @override
  String get newDeckButton => 'Nuevo mazo';

  @override
  String get createDeckTitle => 'Crear nuevo mazo';

  @override
  String get deckNameLabel => 'Nombre del mazo';

  @override
  String get deckFormatLabel => 'Formato (ej. Commander, Standard)';

  @override
  String get importExportDeckButton => 'Importar / Exportar';

  @override
  String get deckIoHint =>
      'Una carta por línea (ej. 1 Sol Ring o 4 Lightning Bolt)';

  @override
  String get applyDecklistButton => 'Aplicar lista';

  @override
  String get copyDecklistButton => 'Copiar lista';

  @override
  String get deckCopiedMessage => 'Lista de mazo copiada al portapapeles.';

  @override
  String ownedInShowcaseBadge(int count, String location) {
    return '✓ Físicas ($count): $location';
  }

  @override
  String missingFromShowcasesBadge(String price) {
    return '✗ Faltante en vitrinas · Est. $price';
  }

  @override
  String get ownedVsTotalLabel => 'Físicas en vitrinas';

  @override
  String get missingCostLabel => 'Costo faltantes';

  @override
  String get manaCurveTitle => 'Curva de coste';

  @override
  String get addCardToDeckHint => 'Añadir carta al mazo…';

  @override
  String addedToDeckMessage(String name, String deck) {
    return '«$name» añadida a «$deck».';
  }

  @override
  String get selectDeckTitle => 'Elegir mazo destino';

  @override
  String get noDecksYetMessage =>
      'Aún no tienes mazos creados. Crea el primero para vincular tus cartas.';

  @override
  String get scannerZoneTitleLabel => 'NOMBRE';

  @override
  String get scannerZoneSetLabel => 'SET · N.º';

  @override
  String get scannerStreamActiveBadge => '⚡ STREAM ÓPTICO EN VIVO';

  @override
  String scannerVariantSelectorLabel(int count) {
    return 'Ediciones detectadas ($count)';
  }

  @override
  String scannerCenteringLabel(String ratio, String grade) {
    return 'Pre-Grading · Centrado $ratio ($grade)';
  }

  @override
  String get proofSnapshotSavedBadge => '📸 Evidencia física capturada';

  @override
  String get viewOfficialArtToggle => 'Arte Oficial';

  @override
  String get viewProofPhotoToggle => 'Foto Escaneada';

  @override
  String get trashBinTitle => 'Papelera de Eliminación';

  @override
  String get trashBinSubtitle =>
      'Las piezas eliminadas se guardan aquí por seguridad. Puedes restaurarlas a su bolsillo o vaciarlas definitivamente.';

  @override
  String get trashBinEmptyMessage => 'La papelera está vacía.';

  @override
  String trashBinCountBadge(int count) {
    return 'Papelera ($count)';
  }

  @override
  String get moveToTrashButton => 'Enviar a la papelera';

  @override
  String moveToTrashConfirm(String name) {
    return '«$name» saldrá del bolsillo y pasará a la Papelera de Eliminación (podrás restaurarla cuando quieras).';
  }

  @override
  String movedToTrashMessage(String name) {
    return '«$name» enviada a la papelera.';
  }

  @override
  String get undoButton => 'Deshacer';

  @override
  String get restoreFromTrashButton => 'Restaurar';

  @override
  String restoredFromTrashMessage(String name, int pocket) {
    return '«$name» restaurada al bolsillo #$pocket.';
  }

  @override
  String get permanentDeleteButton => 'Eliminar definitivo';

  @override
  String get emptyTrashButton => 'Vaciar papelera';

  @override
  String emptyTrashConfirm(int count) {
    return '¿Eliminar definitivamente las $count piezas de la papelera? Esta acción no se puede deshacer.';
  }

  @override
  String get trashDropZoneHint => '🗑️ Suelta aquí para enviar a la Papelera';

  @override
  String trashOriginLabel(String binder, int pocket) {
    return 'De: $binder · Bolsillo #$pocket';
  }

  @override
  String get deckGameTypeLabel => 'Juego del mazo';

  @override
  String get deleteDeckButton => 'Eliminar mazo';

  @override
  String get deckFilterAll => 'Todas';

  @override
  String get deckFilterOwned => '✓ En Vitrinas';

  @override
  String get deckFilterMissing => '✗ Faltantes';

  @override
  String get pullListButton => 'Lista de Extracción';

  @override
  String get pullListTitle => 'Localizador Físico · Lista de Extracción';

  @override
  String get pullListSubtitle =>
      'Ubicación exacta de cada carta física que debes sacar de tus vitrinas para armar este mazo:';

  @override
  String get pullListEmpty =>
      'Aún no tienes cartas físicas de este mazo localizadas en tus vitrinas.';

  @override
  String get openInShowcaseTooltip => 'Ir a la pieza en vitrina';

  @override
  String get editProfileButton => 'Editar perfil';

  @override
  String get displayNameLabel => 'Nombre visible';

  @override
  String get tradeContactLabel => 'Contacto Tradelist (ej. @usuario / Discord)';

  @override
  String get tradeContactHint =>
      'Visible en tus vitrinas públicas para acordar cambios o ventas';

  @override
  String contactSellerButton(String handle) {
    return 'Contactar ($handle)';
  }

  @override
  String contactCopiedMessage(String handle) {
    return 'Contacto «$handle» copiado al portapapeles.';
  }

  @override
  String get costBasisLabel => 'Costo adquisición';
}
