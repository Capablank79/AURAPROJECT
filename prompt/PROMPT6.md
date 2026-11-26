Lee `GEMINI.md` antes de ejecutar cualquier acción.
Asume que el Prompt #5 (`MlKitService`, `CardScannerScreen` y `CardStrategySheet`) ya está funcionando. Ahora vamos a construir el último módulo del Frontend en **`lib/features/profile/`** (Vitrina Pública Compartible, Perfil del Coleccionista, Monetización Simulada y Moderación).

1. **Rutas Públicas y Vista de Solo Lectura (`PublicBinderScreen` & `app_router.dart`):**
   - Asegúrate de incluir `share_plus` en `pubspec.yaml`.
   - Agrega la ruta `/u/:username/:binderId` en `lib/core/router/app_router.dart` apuntando a `PublicBinderScreen` (tanto accesible dentro de la navegación como preparada para Deep Links).
   - `PublicBinderScreen` debe validar si la carpeta existe y si `binder.isPublic == true` (si `isPublic == false`, muestra un estado elegante de *"Esta vitrina es privada"*).
   - Renderiza la carpeta en **modo estricto de solo lectura**: oculta los botones `+` de los bolsillos vacíos y cualquier acción de edición/eliminación, manteniendo activo el **efecto holográfico giroscópico (`HoloFoilCardWidget`)** y la apertura de la ficha de detalle en modo lectura al tocar un artículo.

2. **Compartir Vitrina y Vista Previa Pública (`BinderDetailScreen`):**
   - Dentro de `BinderDetailScreen` (cuando `binder.isPublic == true`), añade en la barra superior:
     - Un botón de **Compartir** que invoque `Share.share(...)` (`share_plus`) con un mensaje localizado y el enlace `https://auradeck.app/u/{username}/{binderId}`.
     - Un botón de **Vista Previa Pública** que navegue a `/u/{username}/{binderId}` para que el dueño vea exactamente cómo lucirá su carpeta ante otros coleccionistas.

3. **Sistema de Reportes y Moderación (`ReportModel` & `MockReportRepository`):**
   - Crea `ReportModel` en `lib/features/profile/domain/report_model.dart` espejo de `schema_v2.sql`: `id`, `itemId` (`item_id`), `reporterId` (`reporter_id`), `reason`, `status` (`'pending'`, `'reviewed'`, `'dismissed'`) y `createdAt` (`created_at`).
   - Crea la interfaz `ReportRepository` y su implementación `MockReportRepository` con Riverpod.
   - En `PublicBinderScreen`, al abrir la ficha de detalle de cualquier artículo con `sourceType == 'user_upload'`, muestra un menú discreto de 3 puntos con la opción **"Reportar contenido"**. Al tocarlo, abre un modal con motivos predefinidos (*Contenido inapropiado*, *Spam / Publicidad*, *Información falsa*) y guarda la denuncia en `MockReportRepository`.

4. **Pantalla de Perfil, Estadísticas y Puente de Monetización (`ProfileScreen`):**
   - Construye la pestaña **Perfil** en `HomeShellScreen` mostrando:
     - Avatar, `@username`, insignia dorada **"Aura Pro"** (si `isPro == true`) o **"Plan Gratuito"**, y selector rápido para cambiar el **Idioma (Español / English)** en vivo con `LocaleNotifier`.
     - **Panel de Valorización:** Tarjeta oscura (`#12141E`) con borde luminoso que suma automáticamente el `estimatedPrice` de todos los artículos en las carpetas del usuario y muestra el total de piezas registradas.
     - **Tienda de Espacios (Puente RevenueCat):** Muestra el saldo de créditos (`profile.extraBinderCredits`) y botones estilizados en oro (`#FFD700`) para **"Adquirir Carpeta Extra (360 espacios)"** y **"Mejorar a Aura Pro"**, conectados a `BillingService`. En modo prueba, permite simular la compra sumando `+1` crédito a `extraBinderCredits` (o activando `isPro`) y verifica que el flujo de **"Crear Nueva Vitrina"** en `BindersScreen` desbloquee la creación descontando `1` crédito.
     - Si `profile.isAdmin == true` (incluye un toggle discreto de prueba/auditoría si es útil en modo mock), muestra el botón **"Panel de Moderación"** para revisar y actualizar el estado (`reviewed` / `dismissed`) de los reportes en `MockReportRepository`.
     - Botón de **Cerrar Sesión** que regrese a `OnboardingAuthScreen`.

5. **Regla Multiidioma Obligatoria:**
   - Agrega todas las nuevas claves (vista previa pública, vitrina privada, textos de compartir, motivos de reporte, panel de moderación, estadísticas de valorización, tienda de espacios y cierre de sesión) en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` antes de usarlas en la UI, y ejecuta `flutter pub get` y `flutter gen-l10n`.

Divide los modelos, repositorios y widgets en archivos limpios y modulares (idealmente menores a 180 líneas por archivo) y muéstrame el resumen de archivos creados y modificados.