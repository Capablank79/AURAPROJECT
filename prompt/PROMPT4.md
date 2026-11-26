Lee `GEMINI.md` antes de ejecutar cualquier acción.
Asume que el Prompt #3 (modelos `BinderModel`/`ItemModel`, `MockBinderRepository`, vista de carpeta 3x3 y `HoloFoilCardWidget`) ya está funcionando. Ahora vamos a construir el módulo de **Catálogo, Búsqueda por API y Subida Personalizada (`lib/features/catalog/`)** bajo nuestra estrategia *Frontend First*.

1. **Clientes de APIs Externas con `dio` (`lib/features/catalog/data/datasources/`):**
   - Asegúrate de incluir `dio`, `cached_network_image`, `image_picker` y `flutter_image_compress` en `pubspec.yaml`.
   - **Pokémon TCG (`TcgdexRemoteDataSource`):** Conecta a `https://api.tcgdex.net/v2/{lang}/cards?name={query}`, donde `{lang}` proviene del idioma activo (`es` o `en`, con *fallback* automático a `en` si la búsqueda en `es` no devuelve resultados). Mapea cada resultado a `ItemModel` extrayendo `id` (`externalId`), `name`, `image` (anexando `/high.webp` si viene como URL base sin extensión) y guardando en `metadata`: `set_name`, `card_type` (categoría/tipo) y `oracle_text` (ataques/habilidades).
   - **Magic: The Gathering (`ScryfallRemoteDataSource`):** Conecta a `https://api.scryfall.com/cards/search?q={query}+lang:{lang}` con cabecera `User-Agent: AuraDeck/1.0`, haciendo *fallback* automático a `https://api.scryfall.com/cards/search?q={query}` si no hay resultados en el idioma elegido. Mapea cada carta a `ItemModel` extrayendo `id` (`externalId`), `name`, `image_uris['normal']` (o `card_faces[0]['image_uris']['normal']` si aplica), `prices['usd']` (`estimatedPrice` parseado a `double?`) y guardando en `metadata`: `set_name`, `card_type` (`type_line`, ej. `"Creature — Human Cleric"`) y `oracle_text`.
   - Crea un repositorio o provider de catálogo que exponga las búsquedas de forma limpia a la UI.

2. **Pantalla de Agregar Artículo (`AddItemScreen`):**
   - Se abre al tocar un bolsillo vacío (`+`) dentro de `BinderDetailScreen`, recibiendo `binderId` y `positionIndex` (y conectando la ruta/navegación necesaria).
   - Incluye un selector superior con 3 modos: **Pokémon TCG**, **Magic: MTG** y **Objeto Propio (Foto)**.
   - **Modo API (Pokémon / Magic):** Barra de búsqueda oscura con *debounce* de 500ms, cuadrícula de resultados con `cached_network_image`, estados de carga/vacío/error, y al tocar una carta, abre un diálogo rápido para elegir su **Condición** (`NM`, `LP`, `MP`, `Sellado`), activar un *switch* de **"¿Es versión Foil / Holográfica?"** (`isFoil`) y confirmar para insertarla en el bolsillo (`positionIndex`) de la carpeta (`binderId`) vía `MockBinderRepository`.

3. **Flujo de Objeto Propio con Compresión WebP (`CustomItemFormWidget`):**
   - Crea `lib/core/utils/image_compressor.dart` usando `flutter_image_compress` para convertir imágenes desde cámara o galería (`image_picker`) a formato **WebP** con ancho máximo de **1080px** y calidad **80%**, devolviendo tanto la ruta/archivo comprimido como el tamaño original vs. tamaño comprimido (en KB/MB) para mostrarlo en pantalla.
   - Formulario en `CustomItemFormWidget`: captura desde cámara o galería, visualización del ahorro de peso WebP, campos de **Nombre del artículo** (obligatorio), **Categoría/Tipo** (ej. `"Figura"`, `"Cómic"`, `"Carta Gradeada"`), **Condición**, **Precio estimado** (opcional), *switch* de **Efecto Foil / Aura** (`isFoil`) y **Notas personales**. Al guardar, inserta el `ItemModel` (`sourceType: 'user_upload'`) en `binderId` y `positionIndex`.

4. **Regla Multiidioma Obligatoria:**
   - Añade todas las nuevas claves en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` antes de usarlas en la UI (cero textos fijos en widgets) y ejecuta `flutter pub get` y `flutter gen-l10n` al finalizar.

Mantén cada archivo modular y limpio (menor a 180 líneas por archivo) y muéstrame el resumen de archivos creados y modificados.