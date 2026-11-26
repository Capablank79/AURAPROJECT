Lee `GEMINI.md` antes de ejecutar cualquier acción.
Asume que el Prompt #2 (multiidioma, `ProfileModel`, `OnboardingAuthScreen` y `HomeShellScreen`) ya está funcionando. Ahora vamos a construir el corazón visual de la aplicación en **`lib/features/binder/`** bajo nuestra estrategia *Frontend First*.

1. **Modelos de Datos Exactos (`lib/features/binder/domain/`):**
   - Crea `BinderModel` respetando el esquema SQL: `id` (`String`), `userId` (`String`), `title` (`String`), `category` (`String`: `'pokemon'`, `'magic'`, `'custom'`), `gridFormat` (`String`: `'2x2'`, `'3x3'`, `'4x3'`), `maxSlots` (`int`, default `360`), `isFreeTier` (`bool`), `theme` (`String`), `isPublic` (`bool`), y `createdAt` (`DateTime?`), con `copyWith`, `fromJson` y `toJson`.
   - Crea `ItemModel` respetando el esquema SQL: `id` (`String`), `binderId` (`String`), `userId` (`String`), `sourceType` (`String`: `'api_tcgdex'`, `'api_scryfall'`, `'user_upload'`), `externalId` (`String?`), `name` (`String`), `imageUrl` (`String`), `isFoil` (`bool`), `condition` (`String`, default `'NM'`), `estimatedPrice` (`double?`), `positionIndex` (`int`), `metadata` (`Map<String, dynamic>`, ej. `card_type`, `set_name`, `oracle_text`, `subtypes`), `notes` (`String?`), y `createdAt` (`DateTime?`), con `copyWith`, `fromJson` y `toJson`.

2. **Repositorio Simulado (`MockBinderRepository`):**
   - Crea la interfaz abstracta `BinderRepository` y su implementación `MockBinderRepository` expuesta mediante Riverpod (`AsyncNotifier` / providers en `lib/features/binder/data/` o `presentation/providers/`).
   - Incluye **1 carpeta inicial gratuita** (`id: 'binder_free_1'`, `maxSlots: 360`, `gridFormat: '3x3'`, `isFreeTier: true`, título `"Vitrina Principal Aura"`, `category: 'custom'`) con **12 artículos de prueba** distribuidos en distintos `positionIndex` (dejando espacios vacíos intencionales entre páginas para probar el `PageView`):
     - Cartas de Pokémon y Magic con URLs válidas de Scryfall/TCGdex (o placeholders limpios con fallback visual si no hay red), varias con `isFoil: true` y `metadata` enriquecido (ej. `"Criatura — Clérigo"`, nombre de expansión, texto de reglas/efecto y `estimatedPrice`).
     - Al menos **2 artículos personalizados** (`sourceType: 'user_upload'`) simulando figuras de colección con `notes` y `estimatedPrice`.

3. **Widget Estrella: Carta/Pieza con Brillo Giroscópico (`HoloFoilCardWidget`):**
   - Crea `lib/features/binder/presentation/widgets/holo_foil_card_widget.dart` usando `sensors_plus` (cancelando la suscripción en `dispose()`) con *fallback* táctil suave (`GestureDetector` con `onPanUpdate` / `onPanEnd`) para probar en emulador o escritorio sin giroscopio.
   - Si `item.isFoil == true`, proyecta un reflejo degradado holográfico dinámico (`ShaderMask` / `LinearGradient`) combinando los colores oficiales (`#00E5FF`, `#FF007A`, `#FFD700`, `#00FF87`) junto con una leve inclinación 3D (`Matrix4` con perspectiva sutil).

4. **Pantalla de Carpetas y Vista Interior 3x3 (`BindersScreen` & `BinderDetailScreen`):**
   - Conecta la primera pestaña de `HomeShellScreen` (`BindersScreen`) para mostrar las carpetas del usuario, su barra de progreso de espacios (ej. `12 / 360`), insignia de plan gratuito/Pro y un botón destacado en dorado (`AuraDeckColors.solarGold` `#FFD700`) para **"Crear Nueva Vitrina"**.
   - Al tocar **"Crear Nueva Vitrina"**, si el usuario ya cuenta con su carpeta gratuita y no tiene `isPro == true` ni `extraBinderCredits > 0`, abre un modal elegante de *Límite de Capacidad* explicando la carpeta gratuita de 360 espacios y preparando la opción futura de *Aura Pro* o carpeta extra.
   - Al abrir una carpeta (`BinderDetailScreen`), muestra un `PageView` horizontal donde cada página renderiza una cuadrícula de **3x3 (9 bolsillos)** sobre `AuraDeckColors.smokedCharcoal` (`#12141E`), con indicadores de página y contador de espacios.
   - Los bolsillos vacíos muestran un contorno sutil con el ícono `+` para agregar artículo (puede abrir un modal/aviso *Frontend First* listo para conectar el catálogo); los bolsillos ocupados muestran la miniatura con un destello sutil si `isFoil == true`.
   - Al tocar un artículo ocupado, abre un modal o pantalla de detalle ampliada con el `HoloFoilCardWidget` activo y una ficha inferior con su nombre, colección (`set_name`), tipo (`card_type`), efecto/descripción (`oracle_text` o `notes`), condición y precio estimado.

5. **Regla Multiidioma Obligatoria:**
   - Añade todas las claves nuevas (`app_es.arb` y `app_en.arb`) antes de usarlas en la UI (cero textos fijos en widgets) y ejecuta `flutter gen-l10n` al finalizar.

Mantén cada widget en archivos modulares y limpios (idealmente menores a 180 líneas por archivo) y preséntame el resumen de archivos creados y modificados.