# Reglas del proyecto AuraDeck

## Fuente de verdad

- AuraDeck es una aplicación multiplataforma Flutter para Android e iOS.
- La especificación de referencia está en `docs/AuraDeck_Project_Book_Fase1.pdf` y
  `docs/AuraDeck_Project_Book_Fase2.pdf`.
- Ante diferencias entre fases, prevalecen la Fase 2 y `SQL/schema_v2.sql`,
  especialmente en modelo de datos, seguridad, i18n y prioridades técnicas.
- No implementar por anticipado funciones de horizontes posteriores si retrasan o
  contradicen el MVP vigente.

## Stack obligatorio

- Flutter y Dart para todo el cliente móvil.
- Riverpod para estado, dependencias e idioma activo.
- Supabase para PostgreSQL, autenticación, persistencia y Row Level Security.
- Cloudflare R2 para imágenes subidas por usuarios.
- TCGdex y Scryfall para catálogos externos.
- RevenueCat para compras únicas y suscripción Aura Pro.
- Google ML Kit para OCR y traducción offline en fases compatibles.
- `sensors_plus` para iluminación giroscópica y efectos foil.
- `go_router`, `share_plus`, `flutter_image_compress`,
  `flutter_localizations` y `shared_preferences` cuando correspondan.

No introducir un backend paralelo ni duplicar en memoria reglas financieras o de
capacidad que deben residir en PostgreSQL.

## Arquitectura Flutter

- Usar arquitectura Feature-First:

```text
lib/
  core/
    constants/
    services/
    theme/
    utils/
  features/
    auth/
    binder/
    catalog/
    profile/
    deck/
  main.dart
```

- Mantener cada feature desacoplada mediante modelos, repositorios y widgets/capas
  de presentación. La UI no conoce directamente tablas ni clientes HTTP.
- Definir interfaces de repositorio y usar `MockBinderRepository` durante la etapa
  visual; permitir reemplazarlo por `SupabaseBinderRepository` sin modificar los
  widgets.
- Los nombres y tipos de `ProfileModel`, `BinderModel`, `ItemModel`, `DeckModel` y
  sus equivalentes deben coincidir exactamente con las columnas de
  `SQL/schema_v2.sql`.
- Serialización y deserialización deben preservar valores nulos, enums permitidos,
  UUID, fechas UTC, números y `metadata` JSONB.
- Centralizar endpoints, límites, colores, textos y formatos; no duplicarlos en
  widgets.

## Reglas funcionales no negociables

- La primera carpeta del usuario es gratuita, tiene 360 espacios y debe marcarse
  `is_free_tier = true`.
- Carpetas adicionales requieren Aura Pro o un crédito de
  `extra_binder_credits`. La decisión final se valida en el servidor mediante
  trigger y no únicamente en Flutter.
- Respetar formatos `2x2`, `3x3` y `4x3`, el máximo de espacios y la unicidad de
  `position_index` dentro de cada carpeta.
- La carpeta interactiva principal del MVP usa páginas de 9 bolsillos `3x3`.
- Cada `item` pertenece al propietario de su `binder` y usa uno de estos orígenes:
  `api_tcgdex`, `api_scryfall` o `user_upload`.
- No descargar ni guardar imágenes completas de TCGdex o Scryfall cuando baste
  conservar `external_id` y la URL oficial.
- En objetos físicos, comprimir obligatoriamente a WebP con un máximo de 1080 px
  antes de subir a Cloudflare R2.
- El enlace público muestra una vitrina de solo lectura y debe respetar
  `is_public`.
- Los reportes de contenido público deben llegar al flujo de moderación
  (`reports`) con estado inicial `pending`.
- El análisis Aura AI se limita a 3 usos diarios para usuarios gratuitos; Aura Pro
  dispone de análisis ilimitados. La restricción no puede depender solo del cliente.

## Producto y alcance

### Horizonte 1: MVP visual

Priorizar:

1. Selección de idioma y onboarding.
2. Autenticación Google, Apple o correo y perfil automático.
3. Primera carpeta gratuita de 360 espacios.
4. Carpeta `3x3` con navegación por páginas.
5. Efecto holográfico giroscópico.
6. Búsqueda en TCGdex/Scryfall con debounce de 500 ms.
7. Subida de foto comprimida como WebP.
8. Vitrina pública compartible.
9. Reporte de artículos públicos.

### Horizontes posteriores

- Horizonte 2: ficha técnica, Aura AI, constructor de mazos, simulador y
  RevenueCat.
- Horizonte 3: ML Kit avanzado, escáner por ráfaga, nuevos catálogos, radar de
  intercambio y funciones B2B.

No mezclar funciones de Horizonte 2 o 3 con el MVP salvo que la tarea las solicite
explícitamente o sean contratos/estructura necesarios para desacoplar el futuro.

## Datos y seguridad

- Activar y mantener RLS en tablas expuestas a usuarios.
- Aplicar principio de mínimo privilegio: el cliente móvil solo usa Project URL y
  llave pública `anon`.
- La clave `service_role`, secretos de administradores, claves de Cloudflare,
  RevenueCat o proveedores de IA están prohibidos en Flutter, repositorio,
  archivos de ejemplo o artefactos compilados.
- La app no debe confiar en que `is_admin`, `is_pro`, créditos, capacidad o precio
  sean verdaderos porque el cliente los envió; validar en SQL, políticas o
  funciones server-side.
- `is_admin` habilita únicamente flujos administrativos autorizados de moderación
  y prueba; no se puede autoasignar desde el cliente.
- `purchase_history.transaction_id` es único y toda compra debe ser auditable.
- No exponer carpetas privadas ni información del propietario fuera de las
  políticas RLS.
- Mantener triggers con controles seguros contra carreras y conservar los nombres
  de contratos actuales: `on_auth_user_created`, `before_insert_binder` y
  `before_insert_item`.
- Para infraestructura nueva, usar Supabase en `sa-east-1` salvo decisión
  documentada.

## Internacionalización

- Escribir desde el primer archivo todo texto visible mediante
  `AppLocalizations` y archivos `.arb`.
- Idiomas base: español, inglés, portugués y japonés (`es`, `en`, `pt`, `ja`).
- Detectar inicialmente `PlatformDispatcher.instance.locale` y permitir cambiarlo
  en onboarding.
- Guardar la preferencia localmente con `shared_preferences` y sincronizarla con
  `profiles.preferred_language` al autenticar.
- El cambio de idioma debe aplicarse sin reiniciar la aplicación.
- Las consultas TCGdex y Scryfall deben usar el idioma activo, con fallback a
  inglés cuando no exista una impresión localizada.
- Las respuestas de Aura AI deben recibir `target_language` con el idioma activo.
- Nunca concatenar traducciones ni construir frases visibles complejas desde
  fragmentos; usar placeholders e ICU en `.arb`.

## UX, accesibilidad y marca

- Diseño Dark Mode nativo con estas bases:
  - Obsidian Void `#06070B`: fondo principal.
  - Smoked Charcoal `#12141E`: superficies, carpetas y cards.
  - Solar Gold `#FFD700`: marca, sigilo, valor y Pro.
  - Mana Cyan `#00E5FF`: maná azul/agua.
  - Psychic Magenta `#FF007A`: energía psíquica.
  - Emerald Aura `#00FF87`: maná verde/planta.
- Conservar una identidad premium, mística y sobria; la experiencia visual debe
  parecer una vitrina, no una hoja de cálculo.
- Mantener etiquetas semánticas, contraste, tamaños táctiles, manejo de foco,
  `SafeArea` y escalado de texto.
- Respetar Reduced Motion y evitar que giroscopio, shimmer o animaciones foil sean
  indispensables para entender la información.
- En dispositivos sin sensor o sin permiso, mostrar un estado estático equivalente
  sin bloquear la navegación.
- Mostrar estados explícitos de carga, vacío, offline, permiso denegado y error.
  No presentar fallbacks como éxito ni ocultar excepciones.

## Integraciones y rendimiento

- Aplicar debounce de 500 ms antes de buscar en catálogos y cancelar solicitudes
  obsoletas.
- Manejar rate limits, timeouts y respuestas parciales de TCGdex y Scryfall con
  errores visibles y reintento.
- Cachear solo datos permitidos; no persistir secretos ni respuestas sensibles.
- Usar imágenes adecuadamente dimensionadas, cache de thumbnails y paginación para
  carpetas grandes.
- Mantener la UI responsive durante OCR, compresión de imagen, consultas y
  animaciones.
- ML Kit debe operar en el dispositivo cuando esté disponible; la función de
  traducción offline debe descargar y gestionar modelos lingüísticos de forma
  explícita.

## Monetización

- Implementar límites del producto como contratos verificables:
  - Carpeta Compacta: 160 espacios.
  - Carpeta Estándar: 360 espacios.
  - Master Set XL: 480 espacios, `4x3`, exclusivo Pro.
- Integrar compras mediante RevenueCat; Flutter nunca confirma compras ni otorga
  beneficios basándose solo en un callback local.
- Los productos gratuitos, de pago único y recurrentes deben conservar IDs estables
  y funcionar en Android e iOS.
- La publicidad, si se incluye, no debe invadir la vitrina ni degradar la
  experiencia de visualización.

## Calidad

- Mantener modelos y lógica de negocio sin dependencias directas de widgets.
- No introducir dependencias globales innecesarias; inyectar servicios y
  repositorios.
- Añadir pruebas unitarias para modelos, serialización, repositorios y límites.
- Añadir pruebas de widget para estados, navegación, localización y accesibilidad de
  flujos críticos.
- Probar al menos Android e iOS para autenticación, deep links, compartir,
  sensores, cámara y compras cuando esas áreas cambien.
- Cuando el proyecto Flutter esté inicializado, validar cambios relevantes con:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
- Antes de publicar, verificar migraciones, políticas RLS, triggers, entornos,
  consentimientos, moderación y revisión de tienda.
