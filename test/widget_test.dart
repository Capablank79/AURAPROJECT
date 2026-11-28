import 'package:aura_deck/app.dart';
import 'package:aura_deck/core/collections/collection_registry.dart';
import 'package:aura_deck/core/models/binder_model.dart';
import 'package:aura_deck/core/models/item_model.dart';
import 'package:aura_deck/core/providers/app_providers.dart';
import 'package:aura_deck/core/services/card_text_extractor_service.dart';
import 'package:aura_deck/core/services/ml_kit_service.dart';
import 'package:aura_deck/features/auth/data/mock_auth_repository.dart';
import 'package:aura_deck/features/auth/providers/auth_providers.dart';
import 'package:aura_deck/features/binder/data/mock_binder_repository.dart';
import 'package:aura_deck/features/binder/presentation/binder_detail_screen.dart';
import 'package:aura_deck/features/binder/presentation/item_detail_screen.dart';
import 'package:aura_deck/features/binder/presentation/widgets/holo_foil_card_widget.dart';
import 'package:aura_deck/features/binder/providers/binder_providers.dart';
import 'package:aura_deck/features/catalog/data/catalog_repository.dart';
import 'package:aura_deck/features/catalog/presentation/catalog_screen.dart';
import 'package:aura_deck/features/catalog/providers/catalog_providers.dart';
import 'package:aura_deck/features/profile/data/report_repository.dart';
import 'package:aura_deck/features/profile/presentation/profile_screen.dart';
import 'package:aura_deck/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('changes language live and persists it', (tester) async {
    final preferences = await _preferences();

    await tester.pumpWidget(_app(preferences));
    await tester.pumpAndSettle();

    expect(find.text('ELIGE TU IDIOMA'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR LANGUAGE'), findsOneWidget);

    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();
    expect(find.text('ESCOLHA SEU IDIOMA'), findsOneWidget);
    expect(preferences.getString(localePreferenceKey), 'pt');

    await tester.tap(find.text('日本語'));
    await tester.pumpAndSettle();
    expect(find.text('言語を選択'), findsOneWidget);
  });

  testWidgets(
    'onboarding goes through language, auth, 2 families, Magic first, and creates showcase',
    (tester) async {
      final preferences = await _preferences();
      final repository = MockBinderRepository();
      final authRepository = MockAuthRepository();

      await tester.pumpWidget(
        _app(
          preferences,
          repository: repository,
          authRepository: authRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Step 0 (Language) -> /auth
      await tester.ensureVisible(find.text('Continuar'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Continuar con Apple'), findsOneWidget);
      expect(find.text('Ingresar con Correo'), findsOneWidget);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      expect(find.text('Cartas coleccionables'), findsOneWidget);
      expect(find.text('Colección de objetos'), findsOneWidget);

      final continueOnFamily = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(continueOnFamily.onPressed, isNull);

      await tester.tap(find.text('Cartas coleccionables'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continuar'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Step 2: Open dropdown and verify Magic appears above Pokemon
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      final magicOption = find.text('Magic: The Gathering').last;
      final pokemonOption = find.text('Pokémon TCG').last;
      expect(
        tester.getTopLeft(magicOption).dy,
        lessThan(tester.getTopLeft(pokemonOption).dy),
      );

      await tester.tap(magicOption);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continuar'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Step 3: Name & create free showcase
      await tester.enterText(find.byType(TextField).first, 'Mis Commanders');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Crear mi vitrina gratis'));
      await tester.tap(find.text('Crear mi vitrina gratis'));
      await tester.pumpAndSettle();

      expect(find.text('Tus vitrinas'), findsOneWidget);
      expect(find.text('Mis Commanders'), findsOneWidget);
      final binders = await repository.getBinders();
      expect(binders.single.collectionCode, 'magic');

      // Settings tab shows active user and sign out redirects to /auth
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('@auracollector'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Cerrar sesión'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(ListView).first, const Offset(0, -140));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(find.text('Continuar con Google'), findsOneWidget);
    },
  );

  testWidgets(
    'second binder closes its sheet cleanly and shows freemium limit',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final binder = _sampleBinder(code: 'magic');
      final repository = MockBinderRepository(binders: [binder]);

      await tester.pumpWidget(_app(preferences, repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nueva vitrina'));
      await tester.pumpAndSettle();

      expect(find.text('Tu vitrina gratuita ya está en uso'), findsOneWidget);

      await tester.tap(find.text('Ver opciones Aura Pro'));
      await tester.pumpAndSettle();

      expect(find.text('Tienda de Espacios'), findsOneWidget);
    },
  );

  testWidgets('add item uses the first empty pocket in the current page', (
    tester,
  ) async {
    final preferences = await _preferences(onboardingComplete: true);
    final binder = _sampleBinder(code: 'magic');
    final firstItem = ItemModel(
      id: 'item-0',
      binderId: binder.id,
      userId: binder.userId,
      collectionCode: 'magic',
      sourceType: 'api_scryfall',
      name: 'Sol Ring',
      imageUrl: 'mock://sol-ring.webp',
      isFoil: true,
      condition: 'NM',
      positionIndex: 0,
      metadata: const {},
      createdAt: DateTime.utc(2026),
    );
    final repository = MockBinderRepository(
      binders: [binder],
      items: [firstItem],
    );

    await tester.pumpWidget(_app(preferences, repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(binder.title));
    await tester.pumpAndSettle();
    expect(find.byType(BinderDetailScreen), findsOneWidget);

    await tester.tap(find.text('Agregar pieza'));
    await tester.pumpAndSettle();

    expect(find.text('Agregar al bolsillo 2'), findsOneWidget);
  });

  testWidgets(
    'Magic showcase locks catalog to Magic; Naruto showcase disables API search',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final magicBinder = _sampleBinder(id: 'b-magic', code: 'magic');
      final narutoBinder = _sampleBinder(id: 'b-naruto', code: 'naruto');
      final repository = MockBinderRepository(
        binders: [magicBinder, narutoBinder],
      );

      // 1. Magic binder: Search enabled, locked to Magic, no Pokemon switch
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            binderRepositoryProvider.overrideWithValue(repository),
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

      expect(find.text('Magic: The Gathering'), findsOneWidget);
      expect(find.text('Pokémon TCG'), findsNothing);
      expect(
        find.text(
          'Solo se muestran cartas de Magic: The Gathering en esta vitrina.',
        ),
        findsOneWidget,
      );

      // 2. Naruto binder: no API -> opens directly in Photo mode with notice
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            binderRepositoryProvider.overrideWithValue(repository),
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
            home: CatalogScreen(binderId: 'b-naruto', positionIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Naruto (Kayou / CCG)'), findsOneWidget);
      expect(
        find.textContaining('Aún no hay catálogo público conectado'),
        findsOneWidget,
      );
      expect(find.text('Nombre de la pieza'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Guardar pieza'), findsOneWidget);
    },
  );

  testWidgets('public item screen is read-only and supports reporting', (
    tester,
  ) async {
    final preferences = await _preferences(onboardingComplete: true);
    final repository = MockBinderRepository.demo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          binderRepositoryProvider.overrideWithValue(repository),
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
          home: ItemDetailScreen(
            binderId: 'pokemon-binder',
            itemId: 'pokemon-151',
            publicView: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guardar cambios'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Ficha técnica'), findsOneWidget);
    expect(find.text('Pokémon 151'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Reportar artículo'), 250);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reportar artículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contenido inapropiado'));
    await tester.pumpAndSettle();
    expect(find.text('Reporte enviado para moderación.'), findsOneWidget);
  });

  testWidgets('foil card respects Reduced Motion with a static fallback', (
    tester,
  ) async {
    final item = ItemModel(
      id: 'foil',
      binderId: 'binder',
      userId: 'user',
      collectionCode: 'magic',
      sourceType: 'user_upload',
      name: 'Foil item',
      imageUrl: 'mock://foil.webp',
      isFoil: true,
      condition: 'NM',
      positionIndex: 0,
      metadata: const {},
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          locale: const Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: HolographicItemCard(item: item, isFoil: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Vista estática. El sensor no está disponible.'),
      findsOneWidget,
    );
  });

  testWidgets('foil card supports touch pan gesture when animations enabled', (
    tester,
  ) async {
    final item = ItemModel(
      id: 'foil-pan',
      binderId: 'binder',
      userId: 'user',
      collectionCode: 'magic',
      sourceType: 'api_scryfall',
      name: 'Sol Ring',
      imageUrl: 'mock://sol-ring.webp',
      isFoil: true,
      condition: 'NM',
      positionIndex: 0,
      metadata: const {},
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: HoloFoilCardWidget(item: item, isFoil: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(HoloFoilCardWidget), const Offset(40, -25));
    await tester.pumpAndSettle();
    expect(find.byType(HoloFoilCardWidget), findsOneWidget);
  });

  testWidgets(
    'catalog search opens condition and foil confirmation dialog before adding',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final binder = _sampleBinder(id: 'b-magic', code: 'magic');
      final repository = MockBinderRepository(binders: [binder]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            binderRepositoryProvider.overrideWithValue(repository),
            catalogRepositoryProvider.overrideWithValue(
              _FakeCatalogRepository(),
            ),
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

      expect(find.text('Sol Ring'), findsAtLeastNWidgets(1));
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar pieza'), findsOneWidget);
      await tester.tap(find.text('¿Es versión Foil / Holográfica?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agregar pieza'));
      await tester.pumpAndSettle();

      final saved = await repository.getItems('b-magic');
      expect(saved, hasLength(1));
      expect(saved.single.isFoil, isTrue);
      expect(saved.single.condition, 'NM');
    },
  );

  testWidgets(
    'item detail 3 tabs: translates effect offline and runs Aura AI analysis',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final binder = _sampleBinder(id: 'b-magic', code: 'magic');
      final item = ItemModel(
        id: 'sol-1',
        binderId: 'b-magic',
        userId: binder.userId,
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        name: 'Sol Ring',
        imageUrl: 'mock://sol-ring.webp',
        isFoil: true,
        condition: 'NM',
        positionIndex: 0,
        metadata: const {
          'expansion': 'Commander Masters',
          'type': 'Artifact',
          'oracleText': 'Tap: Add two colorless mana.',
        },
        createdAt: DateTime.utc(2026),
      );
      final repository = MockBinderRepository(binders: [binder], items: [item]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            binderRepositoryProvider.overrideWithValue(repository),
            mlKitServiceProvider.overrideWithValue(
              const MockMlKitService(stubbedTranslationPrefix: '[Traducido]'),
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
            home: ItemDetailScreen(binderId: 'b-magic', itemId: 'sol-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Traducir efecto offline'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Traducir efecto offline'));
      await tester.pumpAndSettle();
      expect(
        find.text('[Traducido] Tap: Add two colorless mana.'),
        findsOneWidget,
      );

      // Switch to Aura AI tab
      await tester.scrollUntilVisible(
        find.text('Aura AI'),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Aura AI'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('✨ Analizar Sinergias y Combos'));
      await tester.pumpAndSettle();

      expect(find.text('Arquetipos recomendados'), findsOneWidget);
      expect(find.text('◆ Arcane Signet'), findsOneWidget);

      // Switch to Mi Vitrina tab
      await tester.tap(find.text('Mi Vitrina'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Agregar a un Mazo'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Agregar a un Mazo'), findsOneWidget);
    },
  );

  testWidgets(
    'public preview route /u/:username/:binderId opens read-only view',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final repository = MockBinderRepository.demo();

      await tester.pumpWidget(
        _app(
          preferences,
          repository: repository,
          authRepository: MockAuthRepository(
            initialUser: MockAuthRepository.demoUser(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mis Commanders'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Agregar pieza'), findsNothing);
    },
  );

  testWidgets(
    'profile shows valuation, simulates extra binder purchase, and moderates reports',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final repository = MockBinderRepository.demo();
      final reports = MockReportRepository();
      await reports.createReport(
        itemId: 'magic-sol-ring',
        reporterId: 'u1',
        reason: 'Spam o engaño',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            binderRepositoryProvider.overrideWithValue(repository),
            reportRepositoryProvider.overrideWithValue(reports),
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
            home: ProfileScreen(asScaffold: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Valuation sums Sol Ring (24.90) + Mew ex (68.50) = $93.40 USD
      expect(find.text('Panel de Valorización'), findsOneWidget);
      expect(find.text('\$93.40 USD'), findsOneWidget);

      // Buy extra binder credit
      final buyExtraFinder = find.text('Adquirir Carpeta Extra (360 espacios)');
      await tester.scrollUntilVisible(buyExtraFinder, 250);
      await tester.ensureVisible(buyExtraFinder);
      await tester.pumpAndSettle();
      await tester.tap(buyExtraFinder);
      await tester.pumpAndSettle();
      expect(find.text('1 créditos'), findsOneWidget);

      // Enable admin audit mode and moderate pending report
      await tester.scrollUntilVisible(find.text('Modo auditoría Admin'), 250);
      await tester.tap(find.text('Modo auditoría Admin'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Panel de Moderación'), 250);
      await tester.tap(find.text('Panel de Moderación'));
      await tester.pumpAndSettle();
      expect(find.text('Spam o engaño'), findsOneWidget);
      await tester.tap(find.text('Marcar revisado'));
      await tester.pumpAndSettle();
      expect(find.text('REVIEWED'), findsOneWidget);
    },
  );

  testWidgets(
    'empty state Elegir mi primera coleccion opens create binder sheet',
    (tester) async {
      final preferences = await _preferences(onboardingComplete: true);
      final repository = MockBinderRepository(binders: []);

      await tester.pumpWidget(_app(preferences, repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Elegir mi primera colección'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cartas coleccionables'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pokémon TCG').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(TextField).last);
      await tester.enterText(find.byType(TextField).last, 'Mi Primera Vitrina');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Crear vitrina'));
      await tester.tap(find.text('Crear vitrina'));
      await tester.pumpAndSettle();

      expect(find.text('Mi Primera Vitrina'), findsOneWidget);
    },
  );
}

class _FakeCatalogRepository implements CatalogRepository {
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
        imageUrl: 'mock://sol-ring.webp',
        collectionCode: 'magic',
        sourceType: 'api_scryfall',
        metadata: {'expansion': 'Commander Masters'},
      ),
    ];
  }
}

BinderModel _sampleBinder({String id = 'binder-1', String code = 'magic'}) {
  return BinderModel(
    id: id,
    userId: '00000000-0000-0000-0000-000000000010',
    title: 'Vitrina Demo',
    family: 'cards',
    collectionCode: code,
    gridFormat: '3x3',
    maxSlots: 360,
    isFreeTier: true,
    theme: 'obsidian_gold',
    isPublic: true,
    createdAt: DateTime.utc(2026),
  );
}

Future<SharedPreferences> _preferences({
  bool onboardingComplete = false,
}) async {
  SharedPreferences.setMockInitialValues({
    localePreferenceKey: 'es',
    onboardingCompleteKey: onboardingComplete,
  });
  return SharedPreferences.getInstance();
}

Widget _app(
  SharedPreferences preferences, {
  MockBinderRepository? repository,
  MockAuthRepository? authRepository,
}) {
  final effectiveAuth =
      authRepository ??
      MockAuthRepository(
        initialUser: (preferences.getBool(onboardingCompleteKey) ?? false)
            ? MockAuthRepository.demoUser()
            : null,
      );
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      authRepositoryProvider.overrideWithValue(effectiveAuth),
      if (repository != null)
        binderRepositoryProvider.overrideWithValue(repository),
    ],
    child: const AuraDeckApp(),
  );
}
