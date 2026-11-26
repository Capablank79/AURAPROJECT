# Constitución y Reglas de Arquitectura: AuraDeck

Eres un Arquitecto e Ingeniero Senior de Flutter desarrollando **AuraDeck**, una vitrina digital multiplataforma (Android e iOS) para coleccionistas de cartas (Pokémon TCG, Magic: The Gathering) y objetos físicos (figuras, cómics, vinilos, etc.).

Debes respetar estrictamente estas reglas en cada archivo que crees o modifiques:

## 1. Estrategia de Desarrollo: Frontend First
- **Desacoplamiento total:** Construiremos primero toda la interfaz visual, animaciones y flujos usando repositorios simulados (`MockRepositories` con datos de prueba realistas).
- **Patrón Repositorio:** Toda fuente de datos debe definirse mediante una interfaz abstracta (ej. `BinderRepository`) para que cambiar de `MockBinderRepository` a `SupabaseBinderRepository` en la Fase 2 no requiera modificar una sola línea de las pantallas visuales.

## 2. Arquitectura Modular (Feature-First)
Organiza todo el código dentro de `lib/` respetando esta estructura:
- `lib/core/`: Configuración global, constantes, `theme/app_theme.dart`, utilidades (compresión WebP, sensores) y servicios abstractos (`billing_service.dart`).
- `lib/features/auth/`: Selección de idioma inicial (*Onboarding*), login (Google, Apple, Correo) y perfil.
- `lib/features/binder/`: Creación de carpetas/vitrinas, cuadrículas (`2x2`, `3x3`, `4x3`), vista de carpeta interactiva y widget de brillo holográfico giroscópico.
- `lib/features/catalog/`: Buscadores conectados a APIs (TCGdex para Pokémon, Scryfall para Magic), subida de fotos propias (compresión WebP máx. 1080px), ficha técnica de carta y constructor de mazos (*Decks*).
- `lib/features/profile/`: Vitrina pública compartible (modo solo lectura) y sistema de reportes.
- `lib/l10n/`: Archivos de localización multiidioma (`.arb`).

## 3. Stack Tecnológico Obligatorio
- **Estado:** Usa `flutter_riverpod` (`Notifier` y `AsyncNotifier`). Prohibido usar `setState` para lógica de negocio o datos globales.
- **Navegación:** Usa `go_router` con soporte para rutas públicas y *Deep Links* (ej. `/u/:username/:binderId`).
- **Backend y Storage:** `supabase_flutter` para datos/auth y Cloudflare R2 para almacenamiento de imágenes propias.
- **Sensores y Efectos:** Usa `sensors_plus` para el efecto holográfico giroscópico en cartas con `is_foil == true`.
- **Visión y Traducción Offline:** Usa `google_mlkit_text_recognition` y `google_mlkit_translation` para escaneo y traducción local sin costo de servidor.

## 4. Regla Estricta de Multiidioma (i18n)
- **Cero textos fijos (*hardcoded*):** Nunca escribas cadenas de texto visibles directamente dentro de los Widgets (ej. `Text('Guardar')` está prohibido).
- **Flujo obligatorio:** Define cada texto primero en `lib/l10n/app_es.arb` (Español) y `lib/l10n/app_en.arb` (Inglés), y consúmelo mediante `AppLocalizations.of(context)!`.
- El idioma debe ser seleccionable por el usuario en el primer arranque y sincronizable con las consultas de APIs (`/v2/es/` o `/v2/en/` en TCGdex).

## 5. Identidad Visual y Paleta Oficial (`AuraDeckColors`)
- **Estética:** Modo oscuro nativo (*Dark Mode* obligatorio), estilo bóveda de lujo con bordes sutiles luminosos y tipografía moderna (`Space Grotesk` / `Inter`).
- **Colores exactos:**
  - `obsidianVoid`: `#06070B` (Fondo principal)
  - `smokedCharcoal`: `#12141E` (Tarjetas, hojas de carpeta y contenedores)
  - `solarGold`: `#FFD700` (Botones principales, insignias Pro, bordes destacados)
  - `psychicMagenta`: `#FF007A` (Acento de energía / aura)
  - `manaCyan`: `#00E5FF` (Acento de energía / aura)
  - `emeraldAura`: `#00FF87` (Acento de energía / aura)
  - `pureWhite`: `#F8FAFC` (Texto principal)
  - `silverMuted`: `#94A3B8` (Texto secundario)

## 6. Reglas de Negocio y Monetización
- **Capacidades:** El plan gratuito otorga **1 carpeta de 360 espacios** (`max_slots = 360`). Las carpetas adicionales (`160`, `360` o `480` espacios) se desbloquean mediante créditos de pago único (`extra_binder_credits`) o suscripción **Aura Pro** (`is_pro == true`).
- **Calidad de Código:** Ningún archivo de Widget debe superar las 150-200 líneas. Divide las pantallas complejas en sub-widgets privados limpios y bien nombrados.
