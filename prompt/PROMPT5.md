Lee `GEMINI.md` antes de ejecutar cualquier acción.
Asume que el Prompt #4 (`TcgdexRemoteDataSource`, `ScryfallRemoteDataSource`, `AddItemScreen` y compresión WebP) ya está funcionando. Ahora vamos a construir el motor inteligente de **Escaneo, Traducción Offline y Análisis Estratégico (`Aura AI`)** dentro de **`lib/features/catalog/`** y **`lib/core/services/`**.

1. **Dependencias y Servicio de Visión / Traducción Offline (`lib/core/services/ml_kit_service.dart`):**
   - Asegúrate de incluir `google_mlkit_text_recognition`, `google_mlkit_translation` y `camera` en `pubspec.yaml` (y ejecuta `flutter pub get`).
   - Implementa `MlKitService` con su provider de Riverpod:
     - `Future<String> extractCardTitleFromImage(String imagePath)`: procesa la imagen con `TextRecognizer`, prioriza las líneas superiores/de mayor tamaño o relevancia de encabezado (donde suele ir el nombre de la carta en Pokémon y Magic), limpia caracteres extraños o números de colección y devuelve un título limpio listo para buscar en la API.
     - `Future<String> translateTextOffline(String text, String targetLangCode)`: si `text.trim().isEmpty`, retorna `text`; mapea `'es'` / `'en'` (y `'pt'` / `'ja'` si aplica) a `TranslateLanguage`, verifica si el modelo destino está descargado con `OnDeviceTranslatorModelManager` (descargándolo solo si hace falta) y traduce el texto offline en el dispositivo.
     - Incluye método `dispose()` para cerrar limpiamente los recursos de ML Kit.

2. **Escáner Rápido con Cámara (`CardScannerScreen`):**
   - Añade un botón con ícono de escáner/cámara dentro de la barra de búsqueda de `AddItemScreen` (en los modos Pokémon / Magic).
   - Al abrir `CardScannerScreen`, muestra una vista previa de cámara (manejando ciclo de vida de `CameraController` y con opción de respaldo desde galería) con un marco guía rectangular dorado (`#FFD700`) en proporción de carta sobre fondo oscuro (`#06070B`) e instrucciones localizadas.
   - Al capturar o seleccionar la imagen, ejecuta `MlKitService.extractCardTitleFromImage`, regresa el texto detectado a `AddItemScreen`, rellena automáticamente el campo de búsqueda y dispara la búsqueda correspondiente para que el usuario elija la carta y la guarde en su bolsillo (`positionIndex`).

3. **Ficha Estratégica y Asistente "Aura AI" (`CardStrategySheet`):**
   - Actualiza la vista de detalle que se abre al tocar una carta dentro de `BinderDetailScreen` organizándola en **3 pestañas limpias**:
     - **Pestaña 1 — Ficha Técnica:** Muestra `set_name`, `card_type` (ej. *"Criatura — Clérigo"*, *"Artefacto"*, *"Mago"*), `estimatedPrice` y `oracle_text` desde `metadata`. Incluye un botón discreto **"Traducir efecto offline"** que invoca `MlKitService.translateTextOffline` usando el idioma activo de `LocaleNotifier` y muestra el texto traducido (con opción de volver al original).
     - **Pestaña 2 — Aura AI (Combos y Mazos):** Crea la interfaz abstracta `CardStrategyRepository` y su implementación simulada `MockCardStrategyRepository` (preparada para conectar un LLM en el futuro, aceptando `ItemModel` y `targetLanguage`). Al tocar el botón dorado **"✨ Analizar Sinergias y Combos"**, muestra un indicador de carga elegante y presenta:
       1. Arquetipos de mazos donde destaca la carta.
       2. Tres cartas clave con las que forma combos o sinergias, junto con una explicación breve de cada combo.
     - **Pestaña 3 — Mi Vitrina:** Muestra condición física (`condition`), `notes` personales y un botón **"Agregar a un Mazo"** que muestre una confirmación *Frontend First* preparando la futura funcionalidad de `decks`.

4. **Regla Multiidioma Obligatoria:**
   - Agrega todas las nuevas claves (instrucciones del marco de escáner, botón de traducción offline, pestañas *Ficha / Aura AI / Mi Vitrina*, títulos de sinergias, mensajes de carga y confirmación de mazo) en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` antes de usarlas en la UI, y ejecuta `flutter gen-l10n`.

Divide los servicios, repositorios y widgets en archivos limpios y modulares (idealmente menores a 180 líneas por archivo) y muéstrame el resumen de archivos creados y modificados.