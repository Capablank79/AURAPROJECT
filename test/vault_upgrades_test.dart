import 'dart:typed_data';

import 'package:aura_deck/core/collections/collection_registry.dart';
import 'package:aura_deck/core/models/binder_model.dart';
import 'package:aura_deck/core/models/item_model.dart';
import 'package:aura_deck/core/providers/app_providers.dart';
import 'package:aura_deck/core/services/card_text_extractor_service.dart';
import 'package:aura_deck/core/services/ml_kit_service.dart';
import 'package:aura_deck/core/utils/card_art_hasher.dart';
import 'package:aura_deck/features/binder/data/mock_binder_repository.dart';
import 'package:aura_deck/features/binder/presentation/widgets/holo_foil_card_widget.dart';
import 'package:aura_deck/features/binder/providers/binder_providers.dart';
import 'package:aura_deck/features/catalog/data/catalog_repository.dart';
import 'package:aura_deck/features/catalog/presentation/catalog_screen.dart';
import 'package:aura_deck/features/catalog/presentation/decks_screen.dart';
import 'package:aura_deck/features/catalog/presentation/widgets/scanner_ar_hud.dart';
import 'package:aura_deck/features/catalog/providers/catalog_providers.dart';
import 'package:aura_deck/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('dynamic grid helpers return expected slots and columns', () {
    expect(slotsPerSheetForFormat('2x2'), 4);
    expect(gridCrossAxisCountForFormat('2x2'), 2);

    expect(slotsPerSheetForFormat('3x3'), 9);
    expect(gridCrossAxisCountForFormat('3x3'), 3);

    expect(slotsPerSheetForFormat('4x3'), 12);
    expect(gridCrossAxisCountForFormat('4x3'), 4);
  });

  test('swapItemPositions swaps occupied pockets and moves to empty slot', () async {
    final binder = BinderModel(
      id: 'b-1',
      userId: 'u-1',
      title: 'Vault',
      family: 'cards',
      collectionCode: 'magic',
      gridFormat: '3x3',
      maxSlots: 36,
      isFreeTier: true,
      theme: 'obsidian_gold',
      isPublic: true,
      createdAt: DateTime.utc(2026),
    );
    final itemA = ItemModel(
      id: 'a',
      binderId: 'b-1',
      userId: 'u-1',
      collectionCode: 'magic',
      sourceType: 'api_scryfall',
      name: 'Sol Ring',
      imageUrl: 'mock://a.webp',
      isFoil: false,
      condition: 'NM',
      positionIndex: 0,
      metadata: const {'verification_origin': ItemVerificationOrigin.scanned},
      createdAt: DateTime.utc(2026),
    );
    final itemB = itemA.copyWith(name: 'Arcane Signet', positionIndex: 4);
    final itemBWithId = ItemModel(
      id: 'b',
      binderId: 'b-1',
      userId: 'u-1',
      collectionCode: 'magic',
      sourceType: 'api_scryfall',
      name: itemB.name,
      imageUrl: 'mock://b.webp',
      isFoil: true,
      condition: 'NM',
      positionIndex: 4,
      metadata: const {'verification_origin': ItemVerificationOrigin.scanned},
      createdAt: DateTime.utc(2026),
    );

    final repo = MockBinderRepository(
      binders: [binder],
      items: [itemA, itemBWithId],
    );

    await repo.swapItemPositions(
      binderId: 'b-1',
      fromPosition: 0,
      toPosition: 4,
    );
    var items = await repo.getItems('b-1');
    expect(items.firstWhere((i) => i.id == 'a').positionIndex, 4);
    expect(items.firstWhere((i) => i.id == 'b').positionIndex, 0);

    await repo.swapItemPositions(
      binderId: 'b-1',
      fromPosition: 4,
      toPosition: 8,
    );
    items = await repo.getItems('b-1');
    expect(items.firstWhere((i) => i.id == 'a').positionIndex, 8);
  });

  test('portfolioValuation excludes API unverified items and computes ROI & slabs', () async {
    SharedPreferences.setMockInitialValues({'locale': 'es'});
    final prefs = await SharedPreferences.getInstance();

    final binder = BinderModel(
      id: 'b-roi',
      userId: 'u-1',
      title: 'Vault',
      family: 'cards',
      collectionCode: 'pokemon',
      gridFormat: '3x3',
      maxSlots: 36,
      isFreeTier: true,
      theme: 'obsidian_gold',
      isPublic: true,
      createdAt: DateTime.utc(2026),
    );
    final physicalSlab = ItemModel(
      id: 'i-phys',
      binderId: 'b-roi',
      userId: 'u-1',
      collectionCode: 'pokemon',
      sourceType: 'user_upload',
      name: 'Charizard ex',
      imageUrl: 'mock://zard.webp',
      isFoil: true,
      condition: 'NM',
      estimatedPrice: 150.0,
      positionIndex: 0,
      metadata: const {
        'verification_origin': ItemVerificationOrigin.scanned,
        'purchase_cost': 100.0,
        'slab_grader': 'PSA',
        'slab_score': '10',
        'trade_status': ItemTradeStatus.forTrade,
      },
      createdAt: DateTime.utc(2026),
    );
    final apiRef = ItemModel(
      id: 'i-api',
      binderId: 'b-roi',
      userId: 'u-1',
      collectionCode: 'pokemon',
      sourceType: 'api_tcgdex',
      name: 'Umbreon VMAX',
      imageUrl: 'mock://umb.webp',
      isFoil: true,
      condition: 'NM',
      estimatedPrice: 900.0,
      positionIndex: 1,
      metadata: const {
        'verification_origin': ItemVerificationOrigin.apiUnverified,
        'trade_status': ItemTradeStatus.forSale,
      },
      createdAt: DateTime.utc(2026),
    );

    expect(apiRef.isPhysicallyVerified, isFalse);
    expect(apiRef.tradeStatus, ItemTradeStatus.wishlistApi);

    final repo = MockBinderRepository(
      binders: [binder],
      items: [physicalSlab, apiRef],
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        binderRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final valuation = await container.read(portfolioValuationProvider.future);
    expect(valuation.totalItems, 1);
    expect(valuation.unverifiedApiItems, 1);
    expect(valuation.totalValue, 150.0);
    expect(valuation.costBasis, 100.0);
    expect(valuation.netRoi, 50.0);
    expect(valuation.slabsCount, 1);
    expect(valuation.tradeCount, 1);
  });

  testWidgets('API search warns and stamps card as api_unverified', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      localePreferenceKey: 'es',
      onboardingCompleteKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final binder = BinderModel(
      id: 'b-magic',
      userId: '00000000-0000-0000-0000-000000000010',
      title: 'Magic Vault',
      family: 'cards',
      collectionCode: 'magic',
      gridFormat: '3x3',
      maxSlots: 36,
      isFreeTier: true,
      theme: 'obsidian_gold',
      isPublic: true,
      createdAt: DateTime.utc(2026),
    );
    final repo = MockBinderRepository(binders: [binder]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          binderRepositoryProvider.overrideWithValue(repo),
          catalogRepositoryProvider.overrideWithValue(_StubCatalog()),
          cardTextExtractorProvider.overrideWithValue(
            const NoopCardTextExtractorService(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CatalogScreen(binderId: 'b-magic', positionIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Sol Ring');
    await tester.pump(const Duration(milliseconds: 550));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    expect(
      find.text('Inserción desde API sin escaneo físico'),
      findsOneWidget,
    );
    await tester.tap(find.text('Agregar pieza'));
    await tester.pumpAndSettle();

    final saved = await repo.getItems('b-magic');
    expect(saved.single.isPhysicallyVerified, isFalse);
    expect(saved.single.tradeStatus, ItemTradeStatus.wishlistApi);
  });

  testWidgets('DecksScreen locates verified binder cards and ignores API refs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      localePreferenceKey: 'es',
      onboardingCompleteKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final demoRepo = MockBinderRepository.demo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          binderRepositoryProvider.overrideWithValue(demoRepo),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: DecksScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Constructor de Mazos'), findsOneWidget);
    expect(
      find.textContaining('✓ Físicas (1): Mis Commanders · P1 #1'),
      findsOneWidget,
    );
  });

  test('MagicFrame dHash, candidate ranker, and optical centering estimator', () {
    final planeA = Uint8List.fromList(List<int>.generate(64 * 64, (i) => i % 255));
    final planeB = Uint8List.fromList(
      List<int>.generate(64 * 64, (i) => (255 - (i % 255))),
    );

    final hashA = CardArtHasher.computeLuminanceDHash(
      yPlane: planeA,
      width: 64,
      height: 64,
      bytesPerRow: 64,
    );
    final hashB = CardArtHasher.computeLuminanceDHash(
      yPlane: planeB,
      width: 64,
      height: 64,
      bytesPerRow: 64,
    );
    expect(CardArtHasher.hammingDistance64(hashA, hashA), 0);
    expect(CardArtHasher.hammingDistance64(hashA, hashB), greaterThan(20));

    final candidates = [
      const CatalogResult(
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        externalId: 'sol-c21',
        name: 'Sol Ring',
        imageUrl: 'mock://c21.webp',
        metadata: {'expansion': 'Commander 2021', 'set_code': 'C21', 'number': '263'},
      ),
      const CatalogResult(
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        externalId: 'sol-cmm',
        name: 'Sol Ring',
        imageUrl: 'mock://cmm.webp',
        metadata: {'expansion': 'Commander Masters', 'set_code': 'CMM', 'number': '399'},
      ),
    ];
    final ranked = CardArtHasher.rankCandidates(
      candidates,
      const CardScanMatch(
        title: 'Sol Ring',
        setCode: 'CMM',
        collectorNumber: '0399',
      ),
    );
    expect(ranked.first.externalId, 'sol-cmm');

    expect(
      DeviceMlKitService.estimateCentering(
        minLeft: 51,
        maxRight: 951,
        frameWidth: 1000,
      ),
      ('51/49', 'PSA 10'),
    );
    expect(
      DeviceMlKitService.estimateCentering(
        minLeft: 58,
        maxRight: 958,
        frameWidth: 1000,
      ),
      ('58/42', 'PSA 9'),
    );
  });

  testWidgets('MagicFrame AR HUD switches printings, toggles Foil, and proof toggle works', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'locale': 'es'});
    final prefs = await SharedPreferences.getInstance();
    CatalogResult? confirmed;
    bool? confirmedFoil;

    const candidates = [
      CatalogResult(
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        externalId: 'sol-1',
        name: 'Sol Ring',
        imageUrl: 'mock://1.webp',
        estimatedPrice: 10.0,
        metadata: {'expansion': 'Alpha', 'number': '1'},
      ),
      CatalogResult(
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        externalId: 'sol-2',
        name: 'Sol Ring',
        imageUrl: 'mock://2.webp',
        estimatedPrice: 20.0,
        metadata: {'expansion': 'Masterpiece', 'number': '24'},
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: ListView(
              children: [
                ScannerDetectedArHud(
                  candidates: candidates,
                  scanMatch: const CardScanMatch(
                    title: 'Sol Ring',
                    centeringRatio: '51/49',
                    estimatedGrade: 'PSA 10',
                  ),
                  hasProofPhoto: true,
                  onConfirm: (sel, foil) {
                    confirmed = sel;
                    confirmedFoil = foil;
                  },
                  onRescan: () {},
                ),
                HolographicItemCard(
                  item: ItemModel(
                    id: 'p1',
                    binderId: 'b1',
                    userId: 'u1',
                    collectionCode: 'magic',
                    sourceType: 'api_scryfall',
                    name: 'Sol Ring',
                    imageUrl: 'mock://official.webp',
                    isFoil: false,
                    condition: 'NM',
                    positionIndex: 0,
                    metadata: const {
                      'verification_origin': ItemVerificationOrigin.scanned,
                      'proof_image_url': 'mock://proof.webp',
                    },
                    createdAt: DateTime.utc(2026),
                  ),
                  isFoil: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Pre-Grading · Centrado 51/49 (PSA 10)'), findsOneWidget);

    await tester.tap(find.text('Masterpiece #24'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FOIL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar pieza'));
    await tester.pumpAndSettle();

    expect(confirmed?.externalId, 'sol-2');
    expect(confirmedFoil, isTrue);

    await tester.scrollUntilVisible(
      find.text('Foto Escaneada'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Foto Escaneada'), findsOneWidget);
  });

  test('Trash Bin moves items out of binder, restores to pocket, and empties', () async {
    final repo = MockBinderRepository.demo();
    var binderItems = await repo.getItems('main-binder');
    expect(binderItems, hasLength(1));

    final trashed = await repo.moveItemToTrash('magic-sol-ring');
    expect(trashed?.binderTitle, 'Mis Commanders');
    expect(await repo.getItems('main-binder'), isEmpty);
    expect(await repo.getTrashedItems(), hasLength(1));

    final restored = await repo.restoreItemFromTrash('magic-sol-ring');
    expect(restored.positionIndex, 0);
    expect(await repo.getItems('main-binder'), hasLength(1));
    expect(await repo.getTrashedItems(), isEmpty);

    await repo.moveItemToTrash('magic-sol-ring');
    await repo.emptyTrash();
    expect(await repo.getTrashedItems(), isEmpty);
  });

  testWidgets('DecksScreen opens Pull List physical locator with exact binder slot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      localePreferenceKey: 'es',
      onboardingCompleteKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final demoRepo = MockBinderRepository.demo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          binderRepositoryProvider.overrideWithValue(demoRepo),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: DecksScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lista de Extracción'));
    await tester.pumpAndSettle();

    expect(find.text('Localizador Físico · Lista de Extracción'), findsOneWidget);
    expect(find.text('Mis Commanders · P1 #1'), findsOneWidget);
  });
}

class _StubCatalog implements CatalogRepository {
  @override
  Future<List<CatalogResult>> search({
    required CatalogProvider provider,
    required String query,
    required String languageCode,
  }) async {
    return const [
      CatalogResult(
        externalId: 'sol-1',
        name: 'Sol Ring',
        imageUrl: 'mock://sol.webp',
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        estimatedPrice: 2.5,
        metadata: {'expansion': 'Commander Masters'},
      ),
    ];
  }
}
