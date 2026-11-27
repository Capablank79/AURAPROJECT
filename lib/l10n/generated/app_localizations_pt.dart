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
  String get selectLanguage => 'ESCOLHA SEU IDIOMA';

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
  String get continueButton => 'Continuar';

  @override
  String get backButton => 'Voltar';

  @override
  String get chooseCollectionTitle => 'O que você vai colecionar?';

  @override
  String get chooseCollectionSubtitle =>
      'Escolha uma coleção para preparar sua primeira vitrine gratuita.';

  @override
  String get chooseFamilySubtitle =>
      'Escolha primeiro a família. Você poderá criar mais vitrines depois.';

  @override
  String get familyCardsTitle => 'Cartas colecionáveis';

  @override
  String get familyCardsSubtitle =>
      'Magic, Pokémon, Yu-Gi-Oh!, One Piece, Lorcana, Naruto e qualquer jogo de cartas.';

  @override
  String get familyObjectsTitle => 'Coleção de objetos';

  @override
  String get familyObjectsSubtitle =>
      'Figuras, quadrinhos, jogos retrô, estátuas e itens físicos.';

  @override
  String get chooseCardGameTitle => 'Qual jogo de cartas?';

  @override
  String get chooseCardGameSubtitle =>
      'A busca e o scanner são ativados automaticamente quando há catálogo disponível.';

  @override
  String get chooseObjectTypeTitle => 'Qual tipo de objetos?';

  @override
  String get chooseObjectTypeSubtitle =>
      'Registre suas peças com fotografia otimizada em WebP.';

  @override
  String get selectCardGameLabel => 'Jogo de cartas';

  @override
  String get selectObjectTypeLabel => 'Tipo de coleção';

  @override
  String get filterGamesHint => 'Buscar jogo…';

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
  String get gameOtherCard => 'Outro jogo de cartas…';

  @override
  String get objectFigures => 'Figuras e estátuas';

  @override
  String get objectComics => 'Quadrinhos e mangás';

  @override
  String get objectRetroGames => 'Videogames e consoles';

  @override
  String get objectOther => 'Outro tipo de coleção…';

  @override
  String get customCollectionNameLabel => 'Nome da coleção';

  @override
  String get customCollectionNameHint =>
      'Ex.: Cartas esportivas, TCG regional…';

  @override
  String get capabilitySearchBadge => 'Busca';

  @override
  String get capabilityScannerBadge => 'Scanner';

  @override
  String get capabilityManualOnlyBadge => 'Apenas manual';

  @override
  String get nameYourShowcaseTitle => 'Dê nome à sua vitrine';

  @override
  String get changeSelectionButton => 'Alterar';

  @override
  String get showcaseIncludesTitle => 'ESTA VITRINE INCLUI';

  @override
  String includesCatalogSearch(String collection) {
    return 'Busca no catálogo oficial de $collection';
  }

  @override
  String get includesCameraScanner =>
      'Scanner de cartas com câmera e leitura local';

  @override
  String get includesManualWebp =>
      'Registro fotográfico WebP + leitura local do título';

  @override
  String includesSingleCollectionRule(String collection) {
    return 'Exclusiva para itens de $collection (sem mistura)';
  }

  @override
  String namedCollectionSuggestion(String collection) {
    return 'Minha vitrine de $collection';
  }

  @override
  String get firstBinderNameLabel => 'Nome da sua vitrine';

  @override
  String get firstBinderNameHint => 'Ex.: Meus Commanders favoritos';

  @override
  String get pokemonBinderSuggestion => 'Minha coleção Pokémon';

  @override
  String get magicBinderSuggestion => 'Meus Commanders favoritos';

  @override
  String get customBinderSuggestion => 'Minha vitrine pessoal';

  @override
  String get createFreeBinderButton => 'Criar minha vitrine gratuita';

  @override
  String get freeBinderCapacityHint => '360 espaços · grade 3×3 · grátis';

  @override
  String get categoryPokemonDescription => 'Cartas e expansões de Pokémon TCG.';

  @override
  String get categoryMagicDescription =>
      'Cartas e edições de Magic: The Gathering.';

  @override
  String get categoryCustomDescription =>
      'Figuras, quadrinhos, jogos, retrô e mais.';

  @override
  String selectCategorySemantic(String category) {
    return 'Selecionar $category';
  }

  @override
  String get auraLogoDescription =>
      'Símbolo dourado e halo cromático da AuraDeck';

  @override
  String get navShowcases => 'Minhas vitrines';

  @override
  String get navSearchCollection => 'Buscar nas vitrines';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get auraProBannerTitle => 'Aura Pro';

  @override
  String get auraProBannerSubtitle =>
      'Vitrines ilimitadas e formato Master Set XL';

  @override
  String get searchMyShowcasesLabel => 'Buscar nas suas vitrines';

  @override
  String get searchMyShowcasesHint =>
      'Filtre pelo nome da carta ou objeto salvo';

  @override
  String get noStoredItemsFound => 'Nenhuma peça salva corresponde ainda.';

  @override
  String get yourCollection => 'Suas vitrines';

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
  String get addBinderButton => 'Nova vitrine';

  @override
  String get chooseFirstCollectionButton => 'Escolher minha primeira coleção';

  @override
  String get emptyCollectionTitle => 'Sua vitrine começa aqui';

  @override
  String get emptyCollectionMessage =>
      'Escolha o que colecionar e crie gratuitamente sua primeira vitrine de 360 espaços.';

  @override
  String get changeLanguage => 'Mudar idioma';

  @override
  String get createBinderTitle => 'Criar nova vitrine';

  @override
  String get binderTitleLabel => 'Nome da vitrine';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryPokemon => 'Pokémon';

  @override
  String get categoryMagic => 'Magic';

  @override
  String get categoryCustom => 'Objetos físicos';

  @override
  String get publicBinderLabel => 'Vitrine pública';

  @override
  String get publicBinderHint =>
      'Permite visualização somente leitura por um link.';

  @override
  String get createButton => 'Criar vitrine';

  @override
  String get createBinderError =>
      'Não foi possível criar a vitrine. Verifique os dados e tente novamente.';

  @override
  String get freeTierLimitTitle => 'Sua vitrine gratuita já está em uso';

  @override
  String get freeTierLimitMessage =>
      'O plano gratuito inclui uma vitrine de 360 espaços. Uma vitrine extra exige Aura Pro ou um crédito.';

  @override
  String get notNowButton => 'Agora não';

  @override
  String get viewAuraProButton => 'Ver opções Aura Pro';

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
  String get loading => 'Carregando';

  @override
  String get unavailableBinder => 'Vitrine indisponível';

  @override
  String get shareBinder => 'Compartilhar vitrine';

  @override
  String shareBinderMessage(String url) {
    return 'Veja minha vitrine AuraDeck: https://$url';
  }

  @override
  String pageIndicator(int current, int total) {
    return 'Página $current / $total';
  }

  @override
  String get jumpToPage => 'Ir para uma página';

  @override
  String pageNumber(int number) {
    return 'Página $number';
  }

  @override
  String get jumpButton => 'Ir';

  @override
  String get addItemButton => 'Adicionar peça';

  @override
  String get binderFullButton => 'Vitrine cheia';

  @override
  String get emptyBinderMessage =>
      'Esta vitrine ainda está vazia. Toque em um espaço para adicionar a primeira peça.';

  @override
  String get publicRestrictedTitle => 'Vitrine privada ou indisponível';

  @override
  String get publicRestrictedMessage =>
      'O proprietário não tornou esta vitrine pública.';

  @override
  String get foilBadge => 'FOIL';

  @override
  String openItem(String name) {
    return 'Abrir $name';
  }

  @override
  String get itemUnavailable => 'Artigo indisponível';

  @override
  String conditionValue(String value) {
    return 'Condição: $value';
  }

  @override
  String priceValue(String value) {
    return 'Preço: $value';
  }

  @override
  String get sourceTcgdex => 'Catálogo Pokémon · TCGdex';

  @override
  String get sourceScryfall => 'Catálogo Magic · Scryfall';

  @override
  String get sourceYgoprodeck => 'Catálogo Yu-Gi-Oh! · YGOPRODeck';

  @override
  String get sourceUpload => 'Registro por foto';

  @override
  String get foilLabel => 'Efeito foil';

  @override
  String get foilHint =>
      'Ative o reflexo holográfico e a iluminação cromática.';

  @override
  String get notesLabel => 'Notas';

  @override
  String get saveChangesButton => 'Salvar alterações';

  @override
  String get deleteItemButton => 'Remover da vitrine';

  @override
  String get saved => 'Alterações salvas';

  @override
  String get deleteItemTitle => 'Remover peça';

  @override
  String deleteItemMessage(String name) {
    return 'Remover «$name» desta vitrine?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Remover';

  @override
  String get reportItemButton => 'Denunciar artigo';

  @override
  String get reportReasonTitle => 'Por que você deseja denunciar este artigo?';

  @override
  String get reasonInappropriate => 'Conteúdo inapropriado';

  @override
  String get reasonCopyright => 'Violação de direitos autorais';

  @override
  String get reasonSpam => 'Spam ou engano';

  @override
  String get reasonOther => 'Outro motivo';

  @override
  String get reportSubmitted => 'Denúncia enviada para moderação.';

  @override
  String get gyroscopeActive =>
      'Iluminação giroscópica ativa. Incline o dispositivo.';

  @override
  String get gyroscopeFallback =>
      'Visão estática. O sensor não está disponível.';

  @override
  String itemImageDescription(String name) {
    return 'Imagem de $name';
  }

  @override
  String get staticViewButton => 'Voltar à visão estática';

  @override
  String get previewShineButton => 'Testar brilho sem sensor';

  @override
  String addToPocketTitle(int number) {
    return 'Adicionar ao bolso $number';
  }

  @override
  String get modeSearchLabel => 'Buscar';

  @override
  String get modeScanLabel => 'Escanear';

  @override
  String get modePhotoLabel => 'Foto';

  @override
  String get lockedCollectionBadge => 'fixo';

  @override
  String noCatalogApiNotice(String collection) {
    return 'ⓘ Ainda não há catálogo público conectado para $collection. Adicione suas peças por foto.';
  }

  @override
  String searchInCollectionHint(String collection) {
    return 'Buscar em $collection…';
  }

  @override
  String onlyCollectionResultsNotice(String collection) {
    return 'Apenas cartas de $collection aparecem nesta vitrine.';
  }

  @override
  String collectionMismatchError(String collection) {
    return 'Esta vitrine aceita apenas itens de $collection.';
  }

  @override
  String get pocketOccupiedError =>
      'Este espaço já está ocupado. Escolha outro bolso.';

  @override
  String scannerHeadline(String collection) {
    return 'Escanear carta · $collection';
  }

  @override
  String get scannerSubtitle =>
      'Capture a carta para ler o nome e buscá-la no catálogo oficial.';

  @override
  String get ocrNoTextDetected =>
      'Nenhum título claro foi detectado. Você pode buscar pelo nome ou enviar a foto.';

  @override
  String get searchCardTab => 'Buscar carta';

  @override
  String get physicalObjectTab => 'Objeto físico';

  @override
  String get searchCardLabel => 'Nome da carta';

  @override
  String get searchCardHint => 'Digite para buscar no catálogo';

  @override
  String get catalogOffline =>
      'Sem conexão. Verifique a rede e tente novamente.';

  @override
  String get catalogRateLimited =>
      'O catálogo atingiu o limite temporário. Tente mais tarde.';

  @override
  String get catalogUnavailable => 'O catálogo está indisponível no momento.';

  @override
  String get searchInstructions => 'Busque uma carta no catálogo.';

  @override
  String get noResults => 'Nenhuma carta encontrada com esse nome.';

  @override
  String get itemNameLabel => 'Nome da peça';

  @override
  String get conditionLabel => 'Condição';

  @override
  String get conditionNm => 'Quase nova (NM)';

  @override
  String get conditionLp => 'Levemente jogada (LP)';

  @override
  String get conditionMp => 'Moderadamente jogada (MP)';

  @override
  String get conditionHp => 'Muito jogada (HP)';

  @override
  String get estimatedPriceLabel => 'Preço estimado';

  @override
  String get imageReady => 'Pronta para comprimir como WebP';

  @override
  String get removeImageButton => 'Remover imagem';

  @override
  String get galleryButton => 'Galeria';

  @override
  String get cameraButton => 'Câmera';

  @override
  String get saveItemButton => 'Salvar peça';

  @override
  String get imagePermissionError =>
      'A imagem não pôde ser selecionada. Verifique as permissões.';

  @override
  String get physicalFormRequired => 'Adicione um nome e selecione uma imagem.';

  @override
  String get imageCompressionError =>
      'Não foi possível comprimir ou salvar a imagem.';

  @override
  String get genericError =>
      'Não foi possível carregar sua coleção. Tente novamente.';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get authSubtitle =>
      'Entre para salvar suas vitrines e acessá-las em qualquer dispositivo.';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get signInWithEmail => 'Entrar com E-mail';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get signInButton => 'Entrar';

  @override
  String get emailPasswordRequired => 'Informe um e-mail válido e sua senha.';

  @override
  String get signOutButton => 'Sair';

  @override
  String get freePlanLabel => 'Plano Gratuito';

  @override
  String get proPlanLabel => 'Aura Pro';

  @override
  String get technicalSheetTitle => 'Ficha técnica';

  @override
  String get expansionLabel => 'Expansão';

  @override
  String get cardTypeLabel => 'Tipo';

  @override
  String get rarityLabel => 'Raridade';

  @override
  String get cardNumberLabel => 'Número';

  @override
  String get rulesTextLabel => 'Texto de regras / habilidades';

  @override
  String get conditionSealed => 'Lacrado (Sealed)';

  @override
  String get itemTypeLabel => 'Categoria ou tipo (opcional)';

  @override
  String get itemTypeHint => 'Ex.: Figura, Quadrinho, Carta graduada';

  @override
  String get confirmAddCardTitle => 'Confirmar peça';

  @override
  String get isFoilQuestion => 'É versão Foil / Holográfica?';

  @override
  String webpSavingsSummary(String original, String compressed) {
    return 'WebP otimizado: $original → $compressed';
  }

  @override
  String get translateOfflineButton => 'Traduzir efeito offline';

  @override
  String get showOriginalTextButton => 'Ver texto original';

  @override
  String get tabSheetLabel => 'Ficha';

  @override
  String get tabAuraAiLabel => 'Aura AI';

  @override
  String get tabShowcaseLabel => 'Minha Vitrine';

  @override
  String get auraAiTitle => 'Aura AI: Combos e Decks';

  @override
  String auraAiRemaining(int remaining, int total) {
    return '$remaining / $total hoje';
  }

  @override
  String get analyzeSynergiesButton => '✨ Analisar Sinergias e Combos';

  @override
  String get auraAiLimitReached =>
      'Você atingiu as 3 análises diárias gratuitas. Assine o Aura Pro para análises ilimitadas.';

  @override
  String get auraAiArchetypesTitle => 'Arquétipos recomendados';

  @override
  String get auraAiCombosTitle => '3 cartas com sinergia principal';

  @override
  String get auraAiTacticalTipTitle => 'Dica tática';

  @override
  String get addToDeckButton => 'Adicionar a um Deck';

  @override
  String get deckBuilderComingSoon =>
      'Construtor de Decks disponível na próxima atualização.';

  @override
  String get scannerCameraFallback =>
      'Câmera indisponível neste dispositivo. Use a Galeria para testar o scanner.';

  @override
  String get scannerGuideHint =>
      'Enquadre o título e a arte da carta dentro da moldura dourada.';

  @override
  String get captureCardButton => 'Capturar e buscar';

  @override
  String get openScannerCameraButton => 'Abrir câmera do scanner';

  @override
  String get publicPreviewButton => 'Prévia Pública';

  @override
  String get valuationPanelTitle => 'Painel de Valorização';

  @override
  String get totalPiecesLabel => 'Itens registrados';

  @override
  String get totalValuationLabel => 'Valor total estimado';

  @override
  String get spaceStoreTitle => 'Loja de Espaços';

  @override
  String binderCreditsCount(int count) {
    return '$count créditos';
  }

  @override
  String get buyExtraBinderButton => 'Adquirir Pasta Extra (360 espaços)';

  @override
  String get upgradeToProButton => 'Assinar Aura Pro';

  @override
  String get purchaseCompletedMessage =>
      'Compra simulada aplicada à sua conta.';

  @override
  String get adminModeLabel => 'Modo auditoria Admin';

  @override
  String get moderationPanelTitle => 'Painel de Moderação';

  @override
  String get moderationEmptyMessage => 'Não há denúncias pendentes de revisão.';

  @override
  String get dismissReportButton => 'Descartar';

  @override
  String get markReviewedButton => 'Marcar revisado';

  @override
  String get countryCurrencyTitle => 'País e moeda';

  @override
  String get countryLabel => 'País';

  @override
  String get selectCountryPrompt => 'Selecione seu país';

  @override
  String get currencyLabel => 'Moeda';

  @override
  String get searchCountryHint => 'Buscar país...';

  @override
  String get searchCurrencyHint => 'Buscar moeda (ex. USD, BRL, EUR)...';

  @override
  String get currencyAutoUpdatedHint =>
      'Ao escolher seu país, a moeda padrão é aplicada, mas você pode alterá-la para USD ou outra quando quiser.';

  @override
  String get spaceBankTitle => 'Banco de Espaços';

  @override
  String get allocatedSlotsLabel => 'Em uso nas vitrines';

  @override
  String get availableSlotsLabel => 'Espaços disponíveis';

  @override
  String get spaceBankHint =>
      'Você escolhe em qual pasta usar seus espaços disponíveis.';

  @override
  String get buySingleSheetButton => 'Adicionar +1 Folha (9 espaços)';

  @override
  String get buyTenSheetsButton => 'Pacote +10 Folhas (90 espaços)';

  @override
  String get upgradeToProAnnualButton => 'Aura Pro Anual (Ilimitado)';

  @override
  String remainingSlotsBanner(int count) {
    return 'Restam $count espaços disponíveis';
  }

  @override
  String get collectionCompleteBadge => 'Coleção Completa';

  @override
  String get completeCollectionButton => 'Coleção completa?';

  @override
  String completeCollectionConfirm(int used, int released) {
    return 'Esta vitrina será ajustada para $used espaços ocupados e os $released espaços restantes voltarão ao seu Banco de Espaços.';
  }

  @override
  String get yesCompleteButton => 'Sim, concluir';

  @override
  String get editBinderTitle => 'Editar vitrina';

  @override
  String get manageSpacesTitle => 'Gerenciar espaços (máx. 900)';

  @override
  String get addSheetFromBankButton => '+1 Folha (+9)';

  @override
  String get releaseEmptySheetButton => '-1 Folha (-9)';

  @override
  String get deleteBinderButton => 'Excluir vitrina';

  @override
  String deleteBinderConfirm(String title, int slots) {
    return '\"$title\" será excluída e todos os $slots espaços voltarão para o seu Banco de Espaços.';
  }

  @override
  String get notEnoughBankSpaces =>
      'Espaços insuficientes no seu Banco. Adquira folhas em Ajustes.';

  @override
  String get navDecks => 'Decks';

  @override
  String get apiPolicyBannerTitle => 'Política de Autenticidade Física';

  @override
  String get apiPolicyBannerBody =>
      'Esta vitrine certifica cartas escaneadas com câmera. Se adicionar pela busca da API, ficará marcada publicamente como «API · Sem físico».';

  @override
  String get apiConfirmWarningTitle =>
      'Inserção via API sem escaneamento físico';

  @override
  String get apiConfirmWarningBody =>
      'Receberá o selo público «API · SEM FÍSICO» para indicar que ainda não foi escaneada fisicamente. Não pode ser colocada para troca ou venda.';

  @override
  String get apiUnverifiedBadge => 'API · SEM FÍSICO';

  @override
  String get apiReferenceWatermark => 'REFERÊNCIA API · NÃO FÍSICA';

  @override
  String get physicalVerifiedBadge => 'FÍSICA';

  @override
  String get physicalVerifiedBanner =>
      'Posse física verificada por scanner ou fotografia.';

  @override
  String get apiUnverifiedBannerTitle =>
      'Aviso público: Sem exemplar físico verificado';

  @override
  String get apiUnverifiedBannerBody =>
      'Adicionada pela API como referência. Não soma ao patrimônio físico nem entra em troca ou venda.';

  @override
  String get verifyWithScannerButton => '📷 Já tenho: Verificar com scanner';

  @override
  String get verifiedSuccessMessage =>
      'Peça verificada como exemplar físico escaneado!';

  @override
  String get trustBadgeFullPhysical => '🛡️ 100% Física Escaneada';

  @override
  String trustBadgeHasApi(int count) {
    return '☁️ $count via API sem verificar';
  }

  @override
  String get filterAll => 'Todas';

  @override
  String get filterPhysicalOnly => '📸 Só Físicas';

  @override
  String get filterForTrade => '🔄 Troca';

  @override
  String get filterForSale => '💲 Venda';

  @override
  String get tradeStatusLabel => 'Status comercial (Tradelist)';

  @override
  String get tradeStatusNone => 'Apenas coleção';

  @override
  String get tradeStatusForTrade => 'Disponível para troca';

  @override
  String get tradeStatusForSale => 'À venda';

  @override
  String get tradeStatusWishlistApi => 'Referência API (Sem físico)';

  @override
  String get tradeBadgeShort => 'TROCA';

  @override
  String get saleBadgeShort => 'VENDA';

  @override
  String get apiCannotTradeMessage =>
      'Referências de API não escaneadas não podem ser vendidas ou trocadas.';

  @override
  String get slabGraderLabel => 'Certificadora (Slab)';

  @override
  String get slabNoneOption => 'Sem graduação (Raw)';

  @override
  String get slabScoreLabel => 'Nota';

  @override
  String get slabCertLabel => 'Nº Cert.';

  @override
  String get purchaseCostLabel => 'Custo de compra';

  @override
  String get roiLabel => 'Valorização (ROI)';

  @override
  String get slabsCountLabel => 'Slabs certificados';

  @override
  String get tradelistCountLabel => 'Na Tradelist';

  @override
  String get apiReferencesCountLabel => 'Referências API (não físicas)';

  @override
  String get gridFormatLabel => 'Formato da grade';

  @override
  String get grid2x2Option => '2×2 Compacta (4 por folha)';

  @override
  String get grid3x3Option => '3×3 Padrão (9 por folha)';

  @override
  String get grid4x3ProOption => '4×3 Master XL (12 por folha · Pro)';

  @override
  String get gridProRequiredMessage =>
      'O formato panorâmico 4×3 requer Aura Pro.';

  @override
  String pocketRangeIndicator(int start, int end) {
    return 'Bolsos #$start – #$end';
  }

  @override
  String get dragSwapHint => 'Segure um item para arrastar e trocar de bolso';

  @override
  String get positionsSwappedMessage => 'Posições atualizadas na folha.';

  @override
  String get qrPosterButton => 'Pôster QR Torneio';

  @override
  String get qrPosterTitle => 'Cartão QR da Vitrine';

  @override
  String get qrPosterTopGems => 'TOP PEÇAS FÍSICAS VERIFICADAS';

  @override
  String get shareQrLinkButton => 'Compartilhar link QR';

  @override
  String get batchScannerButton => 'Scanner em lote';

  @override
  String get batchScannerTitle => 'Fila de Scanner em Lote';

  @override
  String get batchScannerHint =>
      'Capture várias cartas seguidas com ML Kit e insira todas juntas em bolsos livres.';

  @override
  String get batchScanNextButton => 'Capturar próxima carta';

  @override
  String get batchGalleryButton => 'Adicionar foto da galeria';

  @override
  String get batchEmptyMessage => 'Ainda não há cartas na fila em lote.';

  @override
  String batchCommitButton(int count) {
    return 'Inserir lote ($count)';
  }

  @override
  String batchCommittedMessage(int count) {
    return '$count peças físicas inseridas em bolsos consecutivos.';
  }

  @override
  String get decksTitle => 'Construtor de Decks';

  @override
  String get decksSubtitle =>
      'Cruze suas listas com suas vitrines físicas verificadas.';

  @override
  String get newDeckButton => 'Novo deck';

  @override
  String get createDeckTitle => 'Criar novo deck';

  @override
  String get deckNameLabel => 'Nome do deck';

  @override
  String get deckFormatLabel => 'Formato (ex. Commander, Standard)';

  @override
  String get importExportDeckButton => 'Importar / Exportar';

  @override
  String get deckIoHint =>
      'Uma carta por linha (ex. 1 Sol Ring ou 4 Lightning Bolt)';

  @override
  String get applyDecklistButton => 'Aplicar lista';

  @override
  String get copyDecklistButton => 'Copiar lista';

  @override
  String get deckCopiedMessage => 'Lista copiada para a área de transferência.';

  @override
  String ownedInShowcaseBadge(int count, String location) {
    return '✓ Físicas ($count): $location';
  }

  @override
  String missingFromShowcasesBadge(String price) {
    return '✗ Faltando nas vitrines · Est. $price';
  }

  @override
  String get ownedVsTotalLabel => 'Físicas nas vitrines';

  @override
  String get missingCostLabel => 'Custo faltantes';

  @override
  String get manaCurveTitle => 'Curva de custo';

  @override
  String get addCardToDeckHint => 'Adicionar carta ao deck…';

  @override
  String addedToDeckMessage(String name, String deck) {
    return '«$name» adicionada a «$deck».';
  }

  @override
  String get selectDeckTitle => 'Escolher deck de destino';

  @override
  String get noDecksYetMessage =>
      'Nenhum deck criado ainda. Crie o primeiro para vincular suas cartas.';

  @override
  String get scannerZoneTitleLabel => 'NOME';

  @override
  String get scannerZoneSetLabel => 'SET · N.º';

  @override
  String get scannerStreamActiveBadge => '⚡ STREAM ÓPTICO AO VIVO';

  @override
  String scannerVariantSelectorLabel(int count) {
    return 'Edições detectadas ($count)';
  }

  @override
  String scannerCenteringLabel(String ratio, String grade) {
    return 'Pré-Grading · Centralização $ratio ($grade)';
  }

  @override
  String get proofSnapshotSavedBadge => '📸 Prova física capturada';

  @override
  String get viewOfficialArtToggle => 'Arte Oficial';

  @override
  String get viewProofPhotoToggle => 'Foto Escaneada';

  @override
  String get trashBinTitle => 'Lixeira de Exclusão';

  @override
  String get trashBinSubtitle =>
      'Itens excluídos ficam salvos aqui com segurança. Restaure-os ao bolso ou esvazie definitivamente.';

  @override
  String get trashBinEmptyMessage => 'A lixeira está vazia.';

  @override
  String trashBinCountBadge(int count) {
    return 'Lixeira ($count)';
  }

  @override
  String get moveToTrashButton => 'Enviar para a lixeira';

  @override
  String moveToTrashConfirm(String name) {
    return '«$name» sairá do bolso e irá para a Lixeira (você pode restaurar quando quiser).';
  }

  @override
  String movedToTrashMessage(String name) {
    return '«$name» enviada para a lixeira.';
  }

  @override
  String get undoButton => 'Desfazer';

  @override
  String get restoreFromTrashButton => 'Restaurar';

  @override
  String restoredFromTrashMessage(String name, int pocket) {
    return '«$name» restaurada ao bolso #$pocket.';
  }

  @override
  String get permanentDeleteButton => 'Excluir definitivo';

  @override
  String get emptyTrashButton => 'Esvaziar lixeira';

  @override
  String emptyTrashConfirm(int count) {
    return 'Excluir definitivamente todos os $count itens da lixeira? Esta ação não pode ser desfeita.';
  }

  @override
  String get trashDropZoneHint => '🗑️ Solte aqui para enviar à Lixeira';

  @override
  String trashOriginLabel(String binder, int pocket) {
    return 'De: $binder · Bolso #$pocket';
  }

  @override
  String get deckGameTypeLabel => 'Jogo do deck';

  @override
  String get deleteDeckButton => 'Excluir deck';

  @override
  String get deckFilterAll => 'Todas';

  @override
  String get deckFilterOwned => '✓ Nas Vitrines';

  @override
  String get deckFilterMissing => '✗ Faltando';

  @override
  String get pullListButton => 'Lista de Retirada';

  @override
  String get pullListTitle => 'Localizador Físico · Lista de Retirada';

  @override
  String get pullListSubtitle =>
      'Localização exata de cada carta física que você deve retirar das vitrines:';

  @override
  String get pullListEmpty =>
      'Nenhuma carta física deste deck foi localizada nas suas vitrines ainda.';

  @override
  String get openInShowcaseTooltip => 'Abrir peça na vitrine';

  @override
  String get editProfileButton => 'Editar perfil';

  @override
  String get displayNameLabel => 'Nome de exibição';

  @override
  String get tradeContactLabel => 'Contato Tradelist (ex. @usuario / Discord)';

  @override
  String get tradeContactHint =>
      'Visível nas suas vitrines públicas para combinar trocas ou vendas';

  @override
  String contactSellerButton(String handle) {
    return 'Contatar ($handle)';
  }

  @override
  String contactCopiedMessage(String handle) {
    return 'Contato «$handle» copiado.';
  }

  @override
  String get costBasisLabel => 'Custo de aquisição';
}
