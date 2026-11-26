Lee `GEMINI.md` antes de ejecutar cualquier acción.
Asume que la estructura Feature-First y el tema base (`AuraDeckColors` / `app_theme.dart`) ya están listos. Ahora vamos a construir el módulo de **Multiidioma (i18n)** y la pantalla de **Bienvenida e Inicio de Sesión (`lib/features/auth/`)** bajo nuestra arquitectura *Frontend First*.

1. **Configuración Multiidioma (`l10n`):**
   - Habilita `generate: true` en `pubspec.yaml` (asegurando `flutter_localizations`, `flutter_riverpod`, `go_router` y `shared_preferences`) y configura `l10n.yaml` en la raíz apuntando a `lib/l10n/`.
   - Crea `lib/l10n/app_es.arb` (Español) y `lib/l10n/app_en.arb` (Inglés) sin textos fijos en pantallas futuras. Incluye claves iniciales para: nombre de la app ("AuraDeck"), subtítulo de bienvenida, selector de idioma ("Selecciona tu idioma"), botones de acceso ("Continuar con Google", "Continuar con Apple", "Ingresar con Correo"), y pestañas de navegación ("Mis Vitrinas", "Explorar", "Perfil").
   - Crea `LocaleNotifier` (Riverpod `NotifierProvider` / `StateNotifierProvider` según el estilo del proyecto) en `lib/core/providers/locale_provider.dart` usando `shared_preferences` para detectar el idioma del sistema al arrancar (`PlatformDispatcher.instance.locale`), permitir cambiarlo en vivo y persistirlo (soportando `es`, `en`, `pt` y `ja`, con fallback a `es` o `en`).

2. **Modelos y Repositorio Simulado de Autenticación (`lib/features/auth/`):**
   - Crea `ProfileModel` en `lib/features/auth/domain/profile_model.dart` reflejando exactamente las columnas de `schema_v2.sql`: `id`, `username`, `displayName` (`display_name`), `avatarUrl` (`avatar_url`), `preferredLanguage` (`preferred_language`), `isPro` (`is_pro`), `isAdmin` (`is_admin`), `extraBinderCredits` (`extra_binder_credits`), `revenuecatAppUserId` (`revenuecat_app_user_id`) y `createdAt` (`created_at`), con `copyWith`, `fromJson` y `toJson`.
   - Crea la interfaz abstracta `AuthRepository` y su implementación simulada `MockAuthRepository` que devuelva un usuario de prueba (`username: "coleccionista_aura"`, `displayName: "Coleccionista Aura"`, `extraBinderCredits: 0`, `isPro: false`, `isAdmin: false`) al tocar cualquiera de los botones de inicio de sesión, junto con su provider de Riverpod.

3. **Pantalla de Bienvenida y Selección de Idioma (`OnboardingAuthScreen`):**
   - Diseña una pantalla inmersiva sobre fondo `AuraDeckColors.obsidianVoid` (`#06070B`).
   - En la esquina superior derecha, coloca un selector de idioma tipo píldora elegante (**Español / English**) que actualice el `LocaleNotifier` al instante.
   - En la parte superior/central, muestra el logotipo/sigilo dorado de **AuraDeck** (carga `assets/images/logo_auradeck.png` si existe en assets/el proyecto, o en su defecto un emblema geométrico dorado provisional con halo luminoso sutil usando `#00E5FF`, `#FF007A` y `#00FF87`).
   - Agrega los botones de acceso ("Continuar con Google", "Continuar con Apple" y enlace discreto "Ingresar con Correo") estilizados con superficies `AuraDeckColors.smokedCharcoal` (`#12141E`) y bordes/detalles en `AuraDeckColors.solarGold` (`#FFD700`).

4. **Navegación Inicial (`go_router`) y `HomeShellScreen`:**
   - Crea una vista base `HomeShellScreen` con `NavigationBar` oscura de 3 pestañas (`Mis Vitrinas`, `Explorar`, `Perfil`) usando `AppLocalizations`.
   - Configura `lib/core/router/app_router.dart` y conéctalo en `MaterialApp.router` dentro de `lib/main.dart`, redirigiendo automáticamente de `/onboarding` (`OnboardingAuthScreen`) a `/home` (`HomeShellScreen`) cuando el usuario complete el inicio de sesión simulado.

Ejecuta `flutter pub get` y `flutter gen-l10n` al finalizar para verificar que no existan errores, y muéstrame el resumen de archivos creados y modificados.