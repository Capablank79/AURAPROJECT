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
  String get continueButton => '続ける';

  @override
  String get backButton => '戻る';

  @override
  String get chooseCollectionTitle => '何をコレクションしますか？';

  @override
  String get chooseCollectionSubtitle => '最初の無料展示棚で扱うコレクションを選択してください。';

  @override
  String get chooseFamilySubtitle => 'まずファミリーを選択してください。後から展示棚を追加できます。';

  @override
  String get familyCardsTitle => 'トレーディングカード';

  @override
  String get familyCardsSubtitle =>
      'マジック、ポケモン、遊戯王、ワンピース、ロルカナ、NARUTO などあらゆるカードゲーム。';

  @override
  String get familyObjectsTitle => 'オブジェクトコレクション';

  @override
  String get familyObjectsSubtitle => 'フィギュア、コミック、レトロゲーム、スタチューなどの実物アイテム。';

  @override
  String get chooseCardGameTitle => 'どのカードゲームですか？';

  @override
  String get chooseCardGameSubtitle => '公式カタログ対応タイトルでは検索とスキャナーが自動で有効になります。';

  @override
  String get chooseObjectTypeTitle => 'どの種類のアイテムですか？';

  @override
  String get chooseObjectTypeSubtitle => '最適化された WebP 写真でコレクションを記録します。';

  @override
  String get selectCardGameLabel => 'カードゲーム';

  @override
  String get selectObjectTypeLabel => 'コレクション種別';

  @override
  String get filterGamesHint => 'ゲームを検索…';

  @override
  String get gameMagic => 'Magic: The Gathering';

  @override
  String get gamePokemon => 'ポケモン TCG';

  @override
  String get gameYugioh => '遊戯王 (Yu-Gi-Oh!)';

  @override
  String get gameOnePiece => 'ONE PIECE カードゲーム';

  @override
  String get gameLorcana => 'ディズニー・ロルカナ';

  @override
  String get gameDigimon => 'デジモンカードゲーム';

  @override
  String get gameDragonBall => 'ドラゴンボールスーパーカードゲーム';

  @override
  String get gameStarWars => 'Star Wars: Unlimited';

  @override
  String get gameFleshAndBlood => 'Flesh and Blood';

  @override
  String get gameNaruto => 'NARUTO (Kayou / CCG)';

  @override
  String get gameOtherCard => 'その他のカードゲーム…';

  @override
  String get objectFigures => 'フィギュア・スタチュー';

  @override
  String get objectComics => 'コミック・マンガ';

  @override
  String get objectRetroGames => 'レトロゲーム・本体';

  @override
  String get objectOther => 'その他のコレクション…';

  @override
  String get customCollectionNameLabel => 'コレクション名';

  @override
  String get customCollectionNameHint => '例: スポーツカード、オリジナルTCG…';

  @override
  String get capabilitySearchBadge => '検索対応';

  @override
  String get capabilityScannerBadge => 'スキャン対応';

  @override
  String get capabilityManualOnlyBadge => '手動のみ';

  @override
  String get nameYourShowcaseTitle => '展示棚に名前を付ける';

  @override
  String get changeSelectionButton => '変更';

  @override
  String get showcaseIncludesTitle => 'この展示棚に含まれる機能';

  @override
  String includesCatalogSearch(String collection) {
    return '$collection 公式カタログ検索';
  }

  @override
  String get includesCameraScanner => 'カメラによるカードスキャンと端末内認識';

  @override
  String get includesManualWebp => 'WebP 写真登録 + 端末内タイトル読み取り';

  @override
  String includesSingleCollectionRule(String collection) {
    return '$collection 専用（他タイトルの混在不可）';
  }

  @override
  String namedCollectionSuggestion(String collection) {
    return '$collection の展示棚';
  }

  @override
  String get firstBinderNameLabel => '展示棚の名前';

  @override
  String get firstBinderNameHint => '例: お気に入り統率者';

  @override
  String get pokemonBinderSuggestion => '私のポケモンコレクション';

  @override
  String get magicBinderSuggestion => 'お気に入り統率者';

  @override
  String get customBinderSuggestion => 'マイコレクション展示棚';

  @override
  String get createFreeBinderButton => '無料展示棚を作成';

  @override
  String get freeBinderCapacityHint => '360スロット・3×3グリッド・無料';

  @override
  String get categoryPokemonDescription => 'ポケモン TCG のカードと拡張セット。';

  @override
  String get categoryMagicDescription => 'Magic: The Gathering のカードとセット。';

  @override
  String get categoryCustomDescription => 'フィギュア、コミック、ゲーム、レトロ品など。';

  @override
  String selectCategorySemantic(String category) {
    return '$category を選択';
  }

  @override
  String get auraLogoDescription => 'AuraDeck の黄金の紋章と虹色のオーラ';

  @override
  String get navShowcases => 'マイ展示棚';

  @override
  String get navSearchCollection => '展示棚を検索';

  @override
  String get navSettings => '設定';

  @override
  String get auraProBannerTitle => 'Aura Pro';

  @override
  String get auraProBannerSubtitle => '展示棚無制限＆Master Set XL フォーマット';

  @override
  String get searchMyShowcasesLabel => '保存済みアイテムを検索';

  @override
  String get searchMyShowcasesHint => 'カード名やアイテム名で絞り込み';

  @override
  String get noStoredItemsFound => '一致する保存済みアイテムはまだありません。';

  @override
  String get yourCollection => 'あなたの展示棚';

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
  String get addBinderButton => '新しい展示棚';

  @override
  String get chooseFirstCollectionButton => '最初のコレクションを選ぶ';

  @override
  String get emptyCollectionTitle => 'あなたの展示棚はここから始まります';

  @override
  String get emptyCollectionMessage => '収集するものを選び、360スロットの最初の展示棚を無料で作成してください。';

  @override
  String get changeLanguage => '言語を変更';

  @override
  String get createBinderTitle => '新しい展示棚を作成';

  @override
  String get binderTitleLabel => '展示棚名';

  @override
  String get categoryLabel => 'カテゴリ';

  @override
  String get categoryPokemon => 'ポケモン';

  @override
  String get categoryMagic => 'マジック';

  @override
  String get categoryCustom => '実物';

  @override
  String get publicBinderLabel => '公開展示棚';

  @override
  String get publicBinderHint => '共有リンクで読み取り専用表示を許可します。';

  @override
  String get createButton => '展示棚を作成';

  @override
  String get createBinderError => '展示棚を作成できませんでした。入力内容を確認して再試行してください。';

  @override
  String get freeTierLimitTitle => '無料展示棚は既に使用中です';

  @override
  String get freeTierLimitMessage =>
      '無料プランには360スロットの展示棚1冊が含まれます。追加には Aura Pro またはクレジットが必要です。';

  @override
  String get notNowButton => '今はしない';

  @override
  String get viewAuraProButton => 'Aura Pro を見る';

  @override
  String occupiedCount(int occupied, int total) {
    return '$occupied / $total';
  }

  @override
  String estimatedValue(String value) {
    return '推定価格: $value';
  }

  @override
  String get visibilityPublic => '公開';

  @override
  String get visibilityPrivate => '非公開';

  @override
  String get loading => '読み込み中';

  @override
  String get unavailableBinder => '展示棚を利用できません';

  @override
  String get shareBinder => '展示棚を共有';

  @override
  String shareBinderMessage(String url) {
    return 'AuraDeck の展示棚をご覧ください: https://$url';
  }

  @override
  String pageIndicator(int current, int total) {
    return 'ページ $current / $total';
  }

  @override
  String get jumpToPage => 'ページへ移動';

  @override
  String pageNumber(int number) {
    return '$number ページ';
  }

  @override
  String get jumpButton => '移動';

  @override
  String get addItemButton => 'アイテムを追加';

  @override
  String get binderFullButton => '展示棚がいっぱいです';

  @override
  String get emptyBinderMessage => '展示棚はまだ空です。スロットをタップして最初のアイテムを追加してください。';

  @override
  String get publicRestrictedTitle => '非公開または利用不可';

  @override
  String get publicRestrictedMessage => '所有者がこの展示棚を公開していません。';

  @override
  String get foilBadge => 'FOIL';

  @override
  String openItem(String name) {
    return '$name を開く';
  }

  @override
  String get itemUnavailable => 'アイテムを利用できません';

  @override
  String conditionValue(String value) {
    return '状態: $value';
  }

  @override
  String priceValue(String value) {
    return '価格: $value';
  }

  @override
  String get sourceTcgdex => 'ポケモンカタログ · TCGdex';

  @override
  String get sourceScryfall => 'マジックカタログ · Scryfall';

  @override
  String get sourceYgoprodeck => '遊戯王カタログ · YGOPRODeck';

  @override
  String get sourceUpload => '写真登録';

  @override
  String get foilLabel => 'ホイル効果';

  @override
  String get foilHint => 'ホログラム反射と色彩照明を有効にします。';

  @override
  String get notesLabel => 'メモ';

  @override
  String get saveChangesButton => '変更を保存';

  @override
  String get deleteItemButton => '展示棚から削除';

  @override
  String get saved => '変更を保存しました';

  @override
  String get deleteItemTitle => 'アイテムを削除';

  @override
  String deleteItemMessage(String name) {
    return 'この展示棚から「$name」を削除しますか？';
  }

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get deleteButton => '削除';

  @override
  String get reportItemButton => 'アイテムを報告';

  @override
  String get reportReasonTitle => 'このアイテムを報告する理由は？';

  @override
  String get reasonInappropriate => '不適切なコンテンツ';

  @override
  String get reasonCopyright => '著作権侵害';

  @override
  String get reasonSpam => 'スパムまたは詐欺';

  @override
  String get reasonOther => 'その他';

  @override
  String get reportSubmitted => 'モデレーションに報告を送信しました。';

  @override
  String get gyroscopeActive => 'ジャイロ照明が有効です。端末を傾けてください。';

  @override
  String get gyroscopeFallback => '静的表示です。センサーを利用できません。';

  @override
  String itemImageDescription(String name) {
    return '$name の画像';
  }

  @override
  String get staticViewButton => '静的表示に戻す';

  @override
  String get previewShineButton => 'センサーなしで輝きを試す';

  @override
  String addToPocketTitle(int number) {
    return 'ポケット $number に追加';
  }

  @override
  String get modeSearchLabel => '検索';

  @override
  String get modeScanLabel => 'スキャン';

  @override
  String get modePhotoLabel => '写真';

  @override
  String get lockedCollectionBadge => '固定';

  @override
  String noCatalogApiNotice(String collection) {
    return 'ⓘ $collection は現在公開カタログ未対応です。写真で登録してください。';
  }

  @override
  String searchInCollectionHint(String collection) {
    return '$collection を検索…';
  }

  @override
  String onlyCollectionResultsNotice(String collection) {
    return 'この展示棚には $collection のカードのみ表示されます。';
  }

  @override
  String collectionMismatchError(String collection) {
    return 'この展示棚には $collection のアイテムのみ追加できます。';
  }

  @override
  String get pocketOccupiedError => 'このポケットは使用中です。別のスロットを選択してください。';

  @override
  String scannerHeadline(String collection) {
    return 'カードスキャン · $collection';
  }

  @override
  String get scannerSubtitle => 'カードを撮影してタイトルを読み取り、公式カタログを検索します。';

  @override
  String get ocrNoTextDetected => 'タイトルを読み取れませんでした。名前で検索するか写真を登録してください。';

  @override
  String get searchCardTab => 'カード検索';

  @override
  String get physicalObjectTab => '実物';

  @override
  String get searchCardLabel => 'カード名';

  @override
  String get searchCardHint => '入力してカタログを検索';

  @override
  String get catalogOffline => 'オフラインです。ネットワークを確認して再試行してください。';

  @override
  String get catalogRateLimited => 'カタログの一時的な上限に達しました。後で再試行してください。';

  @override
  String get catalogUnavailable => 'カタログは現在利用できません。';

  @override
  String get searchInstructions => 'カタログでカードを検索します。';

  @override
  String get noResults => 'その名前のカードは見つかりませんでした。';

  @override
  String get itemNameLabel => 'アイテム名';

  @override
  String get conditionLabel => '状態';

  @override
  String get conditionNm => 'ニアミント (NM)';

  @override
  String get conditionLp => 'ライトプレイ (LP)';

  @override
  String get conditionMp => 'モデレートプレイ (MP)';

  @override
  String get conditionHp => 'ヘビープレイ (HP)';

  @override
  String get estimatedPriceLabel => '推定価格';

  @override
  String get imageReady => 'WebP 変換の準備完了';

  @override
  String get removeImageButton => '画像を削除';

  @override
  String get galleryButton => 'ギャラリー';

  @override
  String get cameraButton => 'カメラ';

  @override
  String get saveItemButton => 'アイテムを保存';

  @override
  String get imagePermissionError => '画像を選択できませんでした。権限を確認してください。';

  @override
  String get physicalFormRequired => '名前を入力し、画像を選択してください。';

  @override
  String get imageCompressionError => '画像を圧縮または保存できませんでした。';

  @override
  String get genericError => 'コレクションを読み込めませんでした。もう一度お試しください。';

  @override
  String get retryButton => '再試行';

  @override
  String get authSubtitle => 'ログインして展示棚を保存し、どの端末からでもアクセスできます。';

  @override
  String get continueWithGoogle => 'Google で続行';

  @override
  String get continueWithApple => 'Apple で続行';

  @override
  String get signInWithEmail => 'メールでログイン';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get signInButton => 'ログイン';

  @override
  String get emailPasswordRequired => '有効なメールアドレスとパスワードを入力してください。';

  @override
  String get signOutButton => 'ログアウト';

  @override
  String get freePlanLabel => '無料プラン';

  @override
  String get proPlanLabel => 'Aura Pro';

  @override
  String get technicalSheetTitle => 'カードデータ';

  @override
  String get expansionLabel => '収録弾';

  @override
  String get cardTypeLabel => 'タイプ';

  @override
  String get rarityLabel => 'レアリティ';

  @override
  String get cardNumberLabel => '番号';

  @override
  String get rulesTextLabel => '効果・ルールテキスト';

  @override
  String get conditionSealed => '未開封 (Sealed)';

  @override
  String get itemTypeLabel => 'カテゴリ・種別（任意）';

  @override
  String get itemTypeHint => '例: フィギュア、コミック、鑑定済みカード';

  @override
  String get confirmAddCardTitle => 'アイテムを確認';

  @override
  String get isFoilQuestion => 'ホイル / ホロ仕様ですか？';

  @override
  String webpSavingsSummary(String original, String compressed) {
    return 'WebP 最適化: $original → $compressed';
  }

  @override
  String get translateOfflineButton => 'オフライン翻訳';

  @override
  String get showOriginalTextButton => '原文を表示';

  @override
  String get tabSheetLabel => 'データ';

  @override
  String get tabAuraAiLabel => 'Aura AI';

  @override
  String get tabShowcaseLabel => 'マイ展示棚';

  @override
  String get auraAiTitle => 'Aura AI: コンボ＆デッキ';

  @override
  String auraAiRemaining(int remaining, int total) {
    return '本日 $remaining / $total';
  }

  @override
  String get analyzeSynergiesButton => '✨ シナジー・コンボを分析';

  @override
  String get auraAiLimitReached =>
      '無料プランの1日3回の分析上限に達しました。Aura Pro で無制限に利用できます。';

  @override
  String get auraAiArchetypesTitle => 'おすすめアーキタイプ';

  @override
  String get auraAiCombosTitle => '相性の良い3枚のカード';

  @override
  String get auraAiTacticalTipTitle => '戦術アドバイス';

  @override
  String get addToDeckButton => 'デッキに追加';

  @override
  String get deckBuilderComingSoon => 'デッキビルダーは次期アップデートで利用可能になります。';

  @override
  String get scannerCameraFallback => 'この端末ではカメラを利用できません。ギャラリーからテストできます。';

  @override
  String get scannerGuideHint => 'カードのタイトルとイラストを黄金の枠内に合わせてください。';

  @override
  String get captureCardButton => '撮影して検索';

  @override
  String get openScannerCameraButton => 'スキャナーカメラを開く';

  @override
  String get publicPreviewButton => '公開プレビュー';

  @override
  String get valuationPanelTitle => 'コレクション評価額';

  @override
  String get totalPiecesLabel => '登録アイテム数';

  @override
  String get totalValuationLabel => '推定合計金額';

  @override
  String get spaceStoreTitle => 'スロットストア';

  @override
  String binderCreditsCount(int count) {
    return '$count クレジット';
  }

  @override
  String get buyExtraBinderButton => '追加バインダー購入 (360スロット)';

  @override
  String get upgradeToProButton => 'Aura Pro にアップグレード';

  @override
  String get purchaseCompletedMessage => 'テスト購入がアカウントに反映されました。';

  @override
  String get adminModeLabel => '管理者監査モード';

  @override
  String get moderationPanelTitle => 'モデレーションパネル';

  @override
  String get moderationEmptyMessage => '確認待ちの報告はありません。';

  @override
  String get dismissReportButton => '却下';

  @override
  String get markReviewedButton => '確認済みにする';

  @override
  String get countryCurrencyTitle => '国と通貨';

  @override
  String get countryLabel => '国';

  @override
  String get selectCountryPrompt => '国を選択';

  @override
  String get currencyLabel => '通貨';

  @override
  String get searchCountryHint => '国を検索...';

  @override
  String get searchCurrencyHint => '通貨を検索 (例: USD, JPY, EUR)...';

  @override
  String get currencyAutoUpdatedHint =>
      '国を選ぶとデフォルト通貨が設定されますが、いつでもUSDや他の通貨に変更できます。';

  @override
  String get spaceBankTitle => 'スペースバンク';

  @override
  String get allocatedSlotsLabel => '使用中のスロット';

  @override
  String get availableSlotsLabel => '利用可能スロット';

  @override
  String get spaceBankHint => '空きスロットをどのバインダーに使うか自由に選べます。';

  @override
  String get buySingleSheetButton => '+1シート追加 (9スロット)';

  @override
  String get buyTenSheetsButton => '+10シートパック (90スロット)';

  @override
  String get upgradeToProAnnualButton => 'Aura Pro 年額 (無制限)';

  @override
  String remainingSlotsBanner(int count) {
    return '残り $count スロット';
  }

  @override
  String get collectionCompleteBadge => 'コレクション完了';

  @override
  String get completeCollectionButton => 'コレクション完了？';

  @override
  String completeCollectionConfirm(int used, int released) {
    return 'このバインダーは使用中の $used スロットに調整され、残りの $released スロットはスペースバンクに戻ります。';
  }

  @override
  String get yesCompleteButton => 'はい、完了';

  @override
  String get editBinderTitle => 'バインダーを編集';

  @override
  String get manageSpacesTitle => 'スロット管理 (最大900)';

  @override
  String get addSheetFromBankButton => '+1シート (+9)';

  @override
  String get releaseEmptySheetButton => '-1シート (-9)';

  @override
  String get deleteBinderButton => 'バインダーを削除';

  @override
  String deleteBinderConfirm(String title, int slots) {
    return '「$title」を削除し、$slots スロットすべてをスペースバンクに戻します。';
  }

  @override
  String get notEnoughBankSpaces => 'スペースバンクの空きが不足しています。設定からシートを追加してください。';

  @override
  String get navDecks => 'デッキ';

  @override
  String get apiPolicyBannerTitle => '実物認証ポリシー';

  @override
  String get apiPolicyBannerBody =>
      'このバインダーはカメラスキャン済みカードを認証します。API検索から追加した場合、公開画面で「API・実物未確認」と表示されます。';

  @override
  String get apiConfirmWarningTitle => 'スキャンなしのAPI登録';

  @override
  String get apiConfirmWarningBody =>
      'カメラスキャンされていないことを示す「API・実物なし」バッジが付与され、販売・トレード設定はできません。';

  @override
  String get apiUnverifiedBadge => 'API・実物なし';

  @override
  String get apiReferenceWatermark => 'API参照・実物未確認';

  @override
  String get physicalVerifiedBadge => '実物確認済';

  @override
  String get physicalVerifiedBanner => 'スキャナーまたは写真により実物所有が確認されています。';

  @override
  String get apiUnverifiedBannerTitle => '公開通知：実物カード未確認';

  @override
  String get apiUnverifiedBannerBody =>
      'API検索から参照用として追加されました。実物評価額には加算されず、トレード・販売はできません。';

  @override
  String get verifyWithScannerButton => '📷 実物をスキャンして認証する';

  @override
  String get verifiedSuccessMessage => '実物カードとして認証されました！';

  @override
  String get trustBadgeFullPhysical => '🛡️ 100% 実物スキャン済';

  @override
  String trustBadgeHasApi(int count) {
    return '☁️ API参照 $count枚';
  }

  @override
  String get filterAll => 'すべて';

  @override
  String get filterPhysicalOnly => '📸 実物のみ';

  @override
  String get filterForTrade => '🔄 トレード可';

  @override
  String get filterForSale => '💲 販売中';

  @override
  String get tradeStatusLabel => 'トレードステータス';

  @override
  String get tradeStatusNone => 'コレクションのみ';

  @override
  String get tradeStatusForTrade => 'トレード可能';

  @override
  String get tradeStatusForSale => '販売中';

  @override
  String get tradeStatusWishlistApi => 'API参照（実物なし）';

  @override
  String get tradeBadgeShort => 'トレード';

  @override
  String get saleBadgeShort => '販売';

  @override
  String get apiCannotTradeMessage => '未スキャンのAPI参照カードは販売・トレードに設定できません。';

  @override
  String get slabGraderLabel => '鑑定機関 (Slab)';

  @override
  String get slabNoneOption => '未鑑定 (Raw)';

  @override
  String get slabScoreLabel => 'グレード';

  @override
  String get slabCertLabel => '証明番号';

  @override
  String get purchaseCostLabel => '購入価格';

  @override
  String get roiLabel => '評価損益 (ROI)';

  @override
  String get slabsCountLabel => '鑑定スラブ数';

  @override
  String get tradelistCountLabel => 'トレード出品数';

  @override
  String get apiReferencesCountLabel => 'API参照（未確認）';

  @override
  String get gridFormatLabel => 'グリッド形式';

  @override
  String get grid2x2Option => '2×2 コンパクト (4枚/シート)';

  @override
  String get grid3x3Option => '3×3 スタンダード (9枚/シート)';

  @override
  String get grid4x3ProOption => '4×3 マスターXL (12枚/シート・Pro)';

  @override
  String get gridProRequiredMessage => '4×3 形式には Aura Pro が必要です。';

  @override
  String pocketRangeIndicator(int start, int end) {
    return 'ポケット #$start – #$end';
  }

  @override
  String get dragSwapHint => '長押しドラッグでポケットの位置を入れ替えられます';

  @override
  String get positionsSwappedMessage => 'ポケットの位置を更新しました。';

  @override
  String get qrPosterButton => '大会用QRポスター';

  @override
  String get qrPosterTitle => 'バインダーQRカード';

  @override
  String get qrPosterTopGems => '認証済み実物トップカード';

  @override
  String get shareQrLinkButton => 'QRリンクを共有';

  @override
  String get batchScannerButton => '連続スキャン（一括）';

  @override
  String get batchScannerTitle => '連続スキャン待機リスト';

  @override
  String get batchScannerHint => 'ML Kitで複数のカードを続けて読み取り、空きポケットへ一括収納します。';

  @override
  String get batchScanNextButton => '次のカードを撮影';

  @override
  String get batchGalleryButton => 'ギャラリーから追加';

  @override
  String get batchEmptyMessage => '待機リストにカードがありません。';

  @override
  String batchCommitButton(int count) {
    return '一括収納 ($count)';
  }

  @override
  String batchCommittedMessage(int count) {
    return '$count枚の実物カードを連続ポケットに収納しました。';
  }

  @override
  String get decksTitle => 'デッキ構築';

  @override
  String get decksSubtitle => 'デッキリストと認証済み実物バインダーを照合します。';

  @override
  String get newDeckButton => '新規デッキ';

  @override
  String get createDeckTitle => '新しいデッキを作成';

  @override
  String get deckNameLabel => 'デッキ名';

  @override
  String get deckFormatLabel => 'フォーマット (例: Commander, Standard)';

  @override
  String get importExportDeckButton => 'インポート / エクスポート';

  @override
  String get deckIoHint => '1行に1枚入力 (例: 1 Sol Ring)';

  @override
  String get applyDecklistButton => 'リストを反映';

  @override
  String get copyDecklistButton => 'リストをコピー';

  @override
  String get deckCopiedMessage => 'デッキリストをコピーしました。';

  @override
  String ownedInShowcaseBadge(int count, String location) {
    return '✓ 所有 ($count): $location';
  }

  @override
  String missingFromShowcasesBadge(String price) {
    return '✗ 未所有 · 推定 $price';
  }

  @override
  String get ownedVsTotalLabel => 'バインダー所有数';

  @override
  String get missingCostLabel => '不足分の推定額';

  @override
  String get manaCurveTitle => 'コストカーブ';

  @override
  String get addCardToDeckHint => 'デッキにカードを追加…';

  @override
  String addedToDeckMessage(String name, String deck) {
    return '「$name」を「$deck」に追加しました。';
  }

  @override
  String get selectDeckTitle => '追加先デッキを選択';

  @override
  String get noDecksYetMessage => 'デッキがまだありません。最初のデッキを作成してください。';

  @override
  String get scannerZoneTitleLabel => 'カード名';

  @override
  String get scannerZoneSetLabel => 'セット・番号';

  @override
  String get scannerStreamActiveBadge => '⚡ ライブ光学スキャン';

  @override
  String scannerVariantSelectorLabel(int count) {
    return '検出された収録版 ($count)';
  }

  @override
  String scannerCenteringLabel(String ratio, String grade) {
    return 'センタリング $ratio ($grade)';
  }

  @override
  String get proofSnapshotSavedBadge => '📸 実物証明キャプチャ済み';

  @override
  String get viewOfficialArtToggle => '公式アート';

  @override
  String get viewProofPhotoToggle => 'スキャン実物';

  @override
  String get trashBinTitle => '削除ゴミ箱';

  @override
  String get trashBinSubtitle => '削除したカードはここに一時保管されます。元のポケットへ復元、または完全削除できます。';

  @override
  String get trashBinEmptyMessage => 'ゴミ箱は空です。';

  @override
  String trashBinCountBadge(int count) {
    return 'ゴミ箱 ($count)';
  }

  @override
  String get moveToTrashButton => 'ゴミ箱へ移動';

  @override
  String moveToTrashConfirm(String name) {
    return '「$name」をポケットから外してゴミ箱へ移動します（いつでも復元可能）。';
  }

  @override
  String movedToTrashMessage(String name) {
    return '「$name」をゴミ箱へ移動しました。';
  }

  @override
  String get undoButton => '元に戻す';

  @override
  String get restoreFromTrashButton => '復元';

  @override
  String restoredFromTrashMessage(String name, int pocket) {
    return '「$name」をポケット #$pocket に復元しました。';
  }

  @override
  String get permanentDeleteButton => '完全削除';

  @override
  String get emptyTrashButton => 'ゴミ箱を空にする';

  @override
  String emptyTrashConfirm(int count) {
    return 'ゴミ箱内の$count件を完全に削除しますか？元に戻せません。';
  }

  @override
  String get trashDropZoneHint => '🗑️ ここにドロップしてゴミ箱へ送る';

  @override
  String trashOriginLabel(String binder, int pocket) {
    return '元: $binder · ポケット #$pocket';
  }

  @override
  String get deckGameTypeLabel => '対応カードゲーム';

  @override
  String get deleteDeckButton => 'デッキ削除';

  @override
  String get deckFilterAll => 'すべて';

  @override
  String get deckFilterOwned => '✓ 所有済み';

  @override
  String get deckFilterMissing => '✗ 未所有';

  @override
  String get pullListButton => 'ピッキングリスト';

  @override
  String get pullListTitle => '実物ロケーター・ピッキング一覧';

  @override
  String get pullListSubtitle => 'このデッキを組むためにバインダーから取り出す実物カードの位置一覧：';

  @override
  String get pullListEmpty => 'このデッキの実物カードはまだバインダー内にありません。';

  @override
  String get openInShowcaseTooltip => 'バインダー内のカードを開く';

  @override
  String get editProfileButton => 'プロフィール編集';

  @override
  String get displayNameLabel => '表示名';

  @override
  String get tradeContactLabel => 'トレード連絡先 (例: @handle / Discord)';

  @override
  String get tradeContactHint => '公開バインダーに表示され、交換・売買の連絡に使われます';

  @override
  String contactSellerButton(String handle) {
    return '連絡する ($handle)';
  }

  @override
  String contactCopiedMessage(String handle) {
    return '連絡先「$handle」をコピーしました。';
  }

  @override
  String get costBasisLabel => '取得原価';
}
