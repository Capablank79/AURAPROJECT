Actúa como Arquitecto Flutter Senior y especialista en UI/UX para el proyecto **AuraDeck**.

Trabajando bajo metodología **Frontend First** y **Feature-First**, configura la estructura base de Flutter en `lib/` y los archivos de localización sin tocar `schema_v2.sql` ni archivos externos a la app Flutter:

1. **Configuración de Idiomas (`l10n.yaml` y `.arb`):**
   - Configura `flutter_localizations` y generación automática de `AppLocalizations`.
   - Crea `l10n.yaml` apuntando a `lib/l10n` con idioma base `es` y soporte para `es`, `en`, `pt` y `ja`.
   - Crea `app_es.arb`, `app_en.arb`, `app_pt.arb` y `app_ja.arb` con claves iniciales para la marca AuraDeck, selector de idioma/onboarding, navegación principal, carpeta 3x3, buscador TCG, subida física, vitrina pública y reportes (cero textos fijos en pantallas futuras).

2. **Estructura de Carpetas (`lib/`):**
   - `lib/core/constants/` -> `api_constants.dart` (endpoints de TCGdex `/v2/{lang}` y Scryfall, formatos `2x2`/`3x3`/`4x3`, capacidades `160`/`360`/`480` y límites del MVP).
   - `lib/core/theme/` -> `aura_deck_colors.dart` con la paleta oficial en Dark Mode:
     - `obsidianVoid` (`#06070B`)
     - `smokedCharcoal` (`#12141E`)
     - `solarGold` (`#FFD700`)
     - `manaCyan` (`#00E5FF`)
     - `psychicMagenta` (`#FF007A`)
     - `emeraldAura` (`#00FF87`)
     y `aura_deck_theme.dart` con `ThemeData.dark()` coherente con esta paleta.
   - `lib/core/services/` -> `billing_service.dart` (interfaz/puente base desacoplado preparado para RevenueCat sin requerir aún credenciales reales).
   - `lib/core/utils/` -> `webp_compressor.dart` (estructura/firma lista para compresión a WebP máx. 1080px).
   - `lib/shared/models/` -> Modelos Dart espejo exacto de `schema_v2.sql`:
     - `profile_model.dart` (`id`, `username`, `display_name`, `avatar_url`, `preferred_language`, `is_pro`, `is_admin`, `extra_binder_credits`, `revenuecat_app_user_id`, `created_at`)
     - `binder_model.dart` (`id`, `user_id`, `title`, `category`, `grid_format`, `max_slots`, `is_free_tier`, `theme`, `is_public`, `created_at`)
     - `item_model.dart` (`id`, `binder_id`, `user_id`, `source_type`, `external_id`, `name`, `image_url`, `is_foil`, `condition`, `estimated_price`, `position_index`, `metadata`, `notes`, `created_at`)
     - `deck_model.dart` (`id`, `user_id`, `title`, `game_type`, `format`, `card_ids`, `created_at`)
     - `report_model.dart` (`id`, `item_id`, `reporter_id`, `reason`, `status`, `created_at`)
   - `lib/features/auth/`, `lib/features/binder/`, `lib/features/catalog/`, `lib/features/profile/` -> Carpetas base listas para las pantallas y providers con Riverpod.
   - `lib/main.dart` -> Punto de entrada con `ProviderScope`, tema `AuraDeckTheme`, soporte multiidioma (`es`, `en`, `pt`, `ja`) y pantalla inicial de bienvenida/selección de idioma o navegación base conectada a `AppLocalizations`.

3. **Dependencias en `pubspec.yaml`:**
   - Revisa y añade de forma limpia las dependencias necesarias para el MVP y su base (`flutter_riverpod`, `go_router`, `shared_preferences`, `sensors_plus`, `flutter_image_compress`, `share_plus`, `flutter_localizations`, `intl`).

Al finalizar, lista los archivos creados y verifica si falta algún paquete o paso previo a correr `flutter pub get` y `flutter gen-l10n`.