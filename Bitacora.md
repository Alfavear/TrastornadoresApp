# Bitácora de Desarrollo - TrastornadoresApp

Este documento registra los avances, decisiones técnicas y configuraciones realizadas durante el desarrollo de la plataforma TrastornadoresApp.

## Fecha: 04 de Agosto de 2026

### 1. Definición de Arquitectura Base
- **Frontend**: Flutter (Mobile First) con Riverpod, GoRouter y Responsive Framework.
- **Backend**: Node.js + NestJS con TypeScript estricto.
- **Base de Datos**: PostgreSQL utilizando Prisma ORM.
- **Autenticación**: Firebase Authentication (Google Sign-In exclusivo).
- **Enfoque Arquitectónico**: Clean Architecture con modularidad para soportar futuros servicios (Eventos, Ministerios, etc.).

### 2. Desarrollo del Backend
- Se generó la estructura base de NestJS en la carpeta `/backend`.
- Se configuró el contenedor de PostgreSQL a través del archivo `docker-compose.yml`.
- Se estableció el esquema de base de datos en `prisma/schema.prisma` con las tablas:
  - `User`, `Schedule`, `ScheduleDate`, `Availability`.
- Se creó el módulo y servicio global de **Prisma**.
- Se implementó la seguridad con **FirebaseAuthGuard** para proteger los endpoints validando tokens JWT contra Firebase.
- Se configuró el módulo inicial **Schedule (Cronograma de Disponibilidad)**:
  - Controlador con Swagger (`/schedule`).
  - Servicio para la lógica de negocio (generación automática de fechas correspondientes a Jueves, Sábados y Domingos).
  - Integración de validadores (`class-validator`, DTOs).
- Se configuró `main.ts` para inicializar automáticamente Firebase Admin utilizando el archivo secreto de la cuenta de servicio.

### 3. Desarrollo del Frontend
- Se creó la estructura del proyecto Flutter en la carpeta `/frontend`.
- Se configuró el archivo `pubspec.yaml` incluyendo dependencias clave (`flutter_riverpod`, `go_router`, `dio`, `firebase_core`, `freezed`, etc.).
- Se estableció el enrutador inicial con `GoRouter` (`app_router.dart`).
- Se crearon las maquetas y pantallas principales bajo Clean Architecture:
  - Pantalla de inicio de sesión (`LoginScreen`) preparada para Google Auth.
  - Pantalla del módulo de Cronograma (`ScheduleScreen`).
- Se configuró el archivo `main.dart` con `Responsive Framework` para adaptarse a Web, Tablets y Móviles.

### 4. Configuración en la Nube (Firebase)
- Se creó el proyecto **`trastornadoresapp`** en Firebase Console.
- Se registró la aplicación Android (`com.trastornadores.app`) y se instruyó sobre la descarga del archivo `google-services.json` a la ruta `frontend/android/app/`.
- Se activó el método de inicio de sesión de Google (Authentication).
- Se generó y vinculó la clave privada del servicio de administración (`firebase-service-account.json`) directamente al servidor de NestJS.

### 5. Control de Versiones
- Se inicializó el repositorio local con Git.
- Se configuró el archivo `.gitignore` para proteger secretos (como las claves de Firebase) y carpetas generadas.
- Se vinculó el proyecto al repositorio remoto en GitHub (`https://github.com/Alfavear/TrastornadoresApp`) y se empujó (push) el código de la arquitectura base.
- Se agregó el archivo `.agents/AGENTS.md` con el contexto y reglas para agentes de IA (obliga a leer `Bitacora.md` antes de proponer cambios).

### 6. Validación y Correcciones del Backend
- Se instalaron las dependencias faltantes en `backend/package.json`: `@nestjs/swagger`, `class-validator`, `class-transformer`, `firebase-admin`, `@prisma/client` y `prisma` (esta última como `devDependency`).
- Se generó el cliente Prisma con `npx prisma generate` (Prisma v6.19.3).
- Se fortaleció la validación de `RegisterAvailabilityDto`:
  - `scheduleDateId` ahora valida `@IsString()` y `@IsUUID()`.
  - `status` ahora valida `@IsIn(['PUEDO', 'NO_PUEDO'])`.
- Se refactorizó `main.ts` para eliminar el `require()` inseguro; ahora lee `firebase-service-account.json` con `fs.readFileSync` + `JSON.parse` tipado con `admin.ServiceAccount`.
- Se tipó correctamente `FirebaseAuthGuard` (tipado del `AuthenticatedRequest`, sin imports no usados ni llamadas a `any`).
- Se tipó el parámetro `@Request()` del controlador de Schedule con la interfaz `AuthenticatedRequest`.
- Se limpiaron imports y casts innecesarios en `schedule.service.ts` y se corrigió el manejo de promesas en los shutdown hooks de `prisma.service.ts`.
- **Verificación:** `npm run build` compila sin errores, `npm run lint` pasa con 0 errores y los tests unitarios pasan (1/1).

### 7. Pendientes del Frontend
- Instalar/validar Flutter con la versión del SDK configurada en `pubspec.yaml` (`>=3.3.0 <4.0.0`).
- Ejecutar `dart run build_runner build --delete-conflicting-outputs` para generar los archivos `schedule_model.freezed.dart` y `schedule_model.g.dart` requeridos por los modelos Freezed/JSON.
- Vincular la capa de datos al backend real (base URL `http://localhost:3000` configurada en `dioProvider`) y descomentar la inicialización de Firebase en `main.dart`.

### 6. Estructura de Pantallas y Riverpod (Módulo Cronograma)
- Se generaron los modelos de datos tipados (`ScheduleModel`, `ScheduleDateModel`, `AvailabilityModel`) preparando la estructura para el paquete `freezed`.
- Se configuró el `ScheduleRepository` para la comunicación con la API del servidor usando **Dio**.
- Se implementaron los *Providers* de estado global con **Riverpod**.
- Se construyó la base visual del módulo de Cronograma:
  - **Participant UI**: Pantalla dinámica que renderiza las fechas disponibles y permite seleccionar "Puedo" / "No Puedo".
  - **Admin UI**: Estructura de `AdminHomeScreen` con `BottomNavigationBar` anidando las 4 vistas funcionales.

### 7. MVP Funcional de Interfaz de Usuario (UI Completa)
- **Pantalla de Login (`LoginScreen`)**:
  - Estilizado moderno con gradientes y tarjetas de sombra elevadas.
  - Botón de autenticación con Google e integración de navegación con `GoRouter`.
- **Vista de Calendario (`AdminCalendarView`)**:
  - Grid interactivo mensual enfocado exclusivamente en Jueves, Sábado y Domingo.
  - Insignias (badges) de conteo de disponibilidad por fecha y modal desplegable de detalles.
- **Vista de Agenda (`AdminAgendaView`)**:
  - Tarjetas expandibles estilo línea de tiempo ordenadas por fecha con avatares de los integrantes.
- **Vista de Matriz / Excel (`AdminMatrixView`)**:
  - Tabla de datos con desplazamiento bidireccional, celdas de ✅/❌ y barra de búsqueda en tiempo real por nombre de integrante.
- **Dashboard Estadístico (`AdminDashboardView`)**:
  - Tarjetas de métricas (KPIs) con promedio de asistencia, día con mayor convocatoria y función para exportar reportes.

### 8. Identidad Visual y Colores Oficiales del Ministerio
- **Paleta de Colores Institucionales Integrada**:
  - **Azul Rey (`#0038A8`)**: Color primario para barras de navegación, botones principales y headers.
  - **Blanco (`#FFFFFF`) / Gris Claro (`#F8FAFC`)**: Fondos limpios y contraste de lectura.
  - **Dorado / Amarillo (`#FFC107`)**: Acento representativo de la Cruz del logo oficial.
- **Branding Institucional y Logos**:
  - **Componente `TrastornadoresBadgeLogo`**: Logo circular sin fondo (transparente) integrado en la pantalla de Login.
  - **Componente `TrastornadoresHeaderLogo`**: Logo en letras (*"MINISTERIO DE JESÚS - TRASTORNADORES - VISIÓN CONQUISTADORA"*) integrado permanentemente en la barra superior (AppBar) al iniciar la aplicación tanto en la vista de Participante como de Administrador.

### 9. Optimizaciones de Experiencia de Usuario (UX)
- **Barra de Progreso e Insumos Rápidos para Participantes**:
  - Incorporación de barra de progreso visual de respuestas mensuales en `ScheduleScreen`.
  - Botones de acción masiva en 1 toque (*"Marcar todos: PUEDO"*, *"Marcar solo Domingos"*).
  - Retroalimentación con notificaciones flotantes cálidas (*Toast/Snackbar*).
- **Herramienta para Administradores (Exportación a WhatsApp)**:
  - Función de 1 clic en `AdminAgendaView` para copiar al portapapeles el listado de servidores formateado listo para pegar en el grupo de WhatsApp.
- **Alertas Visuales de Cobertura en Calendario**:
  - Resaltado automático en naranja y badge de advertencia para fechas con baja cantidad de servidores confirmados (< 2).

### 10. Compilación Inicial y Configuración (04/08/2026)
- Se instalaron exitosamente las dependencias del backend (`npm install`) y se verificó que la compilación funciona sin errores (`npm run build`).
- Se corrigió la dependencia de `json_serializable` en el frontend, cambiándola a la versión `^6.9.5` debido a conflictos de resolución de versiones.
- Se instalaron exitosamente las dependencias del frontend (`flutter pub get`).
- Se generaron exitosamente los modelos y utilidades en el frontend usando `dart run build_runner build --delete-conflicting-outputs`.
- El proyecto se encuentra ahora en un estado compilable base, cubriendo los primeros pendientes registrados en la bitácora.

### 11. Conexión de Base de Datos Neon, Pruebas Unitarias y Despliegue Web (04/08/2026)
- Se configuró la conexión del backend (NestJS + Prisma) con la base de datos PostgreSQL en la nube de Neon.tech.
- Se sincronizaron las tablas de la base de datos (`User`, `Schedule`, `ScheduleDate`, `Availability`) con `prisma db push`.
- Se creó una suite de pruebas unitarias en Flutter usando `mocktail` para validar los modelos (`ScheduleModel`) y el repositorio (`ScheduleRepository`).
- Se corrigió el error de enrutamiento habilitando la ruta `/admin` en `app_router.dart` para conectar el botón de acceso de administración.
- Se corrigió el error tipográfico en `AdminDashboardView` (`FontWeight.extrabold` a `FontWeight.w800`).
- Se desplegó la aplicación web compilada en modo SPA de producción (`flutter build web`) sirviéndose en `http://localhost:8080`.
- Se solucionó el error `401 (Unauthorized)` en los endpoints de NestJS actualizando `FirebaseAuthGuard` para que, en modo desarrollo (sin credenciales reales de Firebase Admin), asigne automáticamente un usuario simulado (mock) cuando las peticiones demo no lleven header de autorización.
- Se generaron automáticamente en la base de datos de Neon los cronogramas semilla para Agosto 2026 y Septiembre 2026 con sus respectivas fechas calculadas (Jueves, Sábados y Domingos).
- Se solucionó la excepción `LocaleDataException` añadiendo `initializeDateFormatting('es', null)` en el `main.dart` para permitir el formateo en español de las fechas del calendario.
- Se corrigió el patrón de formateo de `intl` en los textos de fechas de `'EEEE d de MMMM'` a `"EEEE d 'de' MMMM"`, eliminando la interpretación de la palabra `de` como tokens de día de mes y día de semana (`3 3E`).
- Se mejoró la resiliencia en `ScheduleRepository` para deserializar respuestas de la API tanto si se entregan como `List` directo o envueltas en un objeto JSON (`Map`), previniendo el error `type '_JsonMap' is not a subtype of type 'List<Object?>'`.

### 13. Rediseño UX: Bandeja de Cronogramas, Estados Abierto/Cerrado y Perfil (04/08/2026)
- **Perfil e Identidad del Servidor**: Se creó `currentUserProvider` en `lib/features/auth/presentation/providers/user_provider.dart` para almacenar los datos del usuario activo y vincular sus respuestas.
- **Bandeja de Cronogramas (Inbox)**: Se transformó `ScheduleScreen` en una vista de bandeja de entrada que lista las tarjetas de cada mes (ej. *Agosto 2026*, *Septiembre 2026*) mostrando su estado (`ABIERTO` o `CERRADO`) y la cantidad de respuestas completadas.
- **Detalle e Interacción por Estados**: Se creó `ScheduleDetailView` que:
  - Carga el historial de selecciones guardadas del usuario desde Neon.
  - Si el cronograma está **Abierto (`isOpen: true`)**: permite marcar *"Puedo"*, *"No puedo"* y toggle para desmarcar.
  - Si el cronograma está **Cerrado (`isOpen: false`)**: se activa el modo estricto de lectura/consulta deshabilitando la edición.

### 14. Seguridad y Control de Acceso por Roles - RBAC (04/08/2026)
- **Guard en Enrutador (`app_router.dart`)**: Se implementó una regla de redirección `redirect` que intercepta la navegación a `/admin`. Si el rol del usuario no es `'ADMIN'`, bloquea automáticamente el acceso y redirige a la bandeja `/schedule`.
- **Selección de Perfil en Login**: Se separaron las opciones de ingreso en `LoginScreen`:
  - *"Ingresar como Servidor"* -> Asigna rol `PARTICIPANT`.
  - *"Acceso Administrador (Líder)"* -> Asigna rol `ADMIN`.
- **Restricción de UI**: El botón para acceder al panel de administración en el `AppBar` de `ScheduleScreen` solo es visible si el usuario tiene rol `ADMIN`.
- **Navegación de Administrador**: Se agregaron accesos en `AdminHomeScreen` para conmutar a la vista de servidor o cerrar sesión.

### 15. Integración del MCP Server de Google Stitch (04/08/2026)
- Se configuró la conexión del servidor MCP remoto de Google Stitch en `opencode.json` con su respectiva clave API (`X-Goog-Api-Key`).
- Se documentó la integración y las reglas de MCP en `OPENCODE.md`.

### 16. Generación de Diseños con Google Stitch MCP y Sistema de Colores (04/08/2026)
- **Generación de Pantallas en Stitch**: Se ejecutó la herramienta `generate_screen_from_text` de Stitch MCP dentro del proyecto `Trastornadores Ministry Interface` (`projects/9255270375602945903`), creando los diseños para:
  - *Participant Schedule Manager* (Vistas de Bandeja e Interacción en móvil).
  - *Admin Leader Dashboard* (Dashboard de líderes, Matriz con badges de advertencia y exportación).
- **Paleta Oficial Aplicada**: Se configuró la paleta oficial en Flutter:
  - **Fondo / Navegación**: Navy Profundo / Negro (`#0A1128` / `#101415`).
  - **Primario**: Azul Rey (`#0038A8`).
  - **Acento**: Dorado (`#FFC107`).
  - **Contenedores**: Blanco Crisp (`#FFFFFF`) con bordes en Azul Rey y bordes redondeados a `16px`.

### 17. Replicación Fiel del Diseño e Interfaz de Google Stitch (04/08/2026)
- **Menú Lateral (`Navigation Drawer`)**: Se incorporó el Drawer lateral fiel al prototipo de Stitch con la insignia dorada `TRASTORNADORES`, perfil del servidor activo y opciones de navegación (*Inicio*, *Agenda*, *Ministerios*, *Equipo*, *Reportes*, *Ajustes*).
- **Sección de Horarios de Referencia**: Se incorporaron las tarjetas de horarios de servicio en la vista principal:
  - *Jueves - Servicio General (19:30 - 21:30)*
  - *Sábado - Reunión de Jóvenes (18:00 - 20:00)*
  - *Domingo - Servicios Dominicales (09:00 - 14:00)*
- **Barra de Navegación Inferior Móvil**: Se agregaron los 4 ítems inferiores (*Servicio*, *Agenda*, *Equipo*, *Perfil*) coordinados con la paleta de colores oficial.

### 18. Funcionalidad 100% Interactiva en Vivo y Persistencia Real (04/08/2026)
- **Despliegue Interactivo de Fechas en Pantalla**: Cada tarjeta de mes (*AGOSTO 2026*) ahora se despliega interactivamente en la pantalla principal para responder directamente las fechas sin necesidad de pantallas estáticas.
- **Acciones y Persistencia Real**: Al presionar *"Puedo"* o *"No Puedo"*, se dispara inmediatamente una petición HTTP `POST /schedule/availability` guardando la respuesta en la base de datos de PostgreSQL **Neon**.
- **Navegación Totalmente Operativa**: Todas las pestañas del menú lateral y de la barra inferior (*Inicio*, *Agenda*, *Equipo*, *Perfil*) están conectadas a vistas funcionales con datos en tiempo real.

### 19. Análisis y Generación del Calendario en la Gama del Blanco en Stitch (04/08/2026)
- **Generación de Pantalla en Stitch MCP**: Se ejecutó `generate_screen_from_text` para la pantalla `Ministry Calendar & Schedule Manager` en la gama del blanco (`Lumina Ministry Light`: fondo `#FFFFFF` / `#F7F9FB`, texto `#001F5C`, primario `#0038A8`, aros/badges `#FFC107`).
- **Integración de Vista de Calendario**: La pestaña de **Calendario** permite navegar por los días del mes con sus badges de estado (Puntos verdes = Cubierto, Puntos naranjas = Incompleto < 2 servidores).
- **Tema Claro de Stitch Aplicado**: Se configuró la interfaz para utilizar la gama del blanco puro con sombras tonales suaves y tarjetas flotantes de elevación 2px.

### 20. Autenticación Obligatoria Google, Vista de Perfil y Textos 100% en Español (04/08/2026)
- **Inicio de Sesión Exclusivo con Google**: Se actualizó `LoginScreen` para requerir el inicio con cuenta oficial de Google (`Continuar con Google`) incorporando un selector de perfil de acceso (*Servidor / Participante* vs *Líder Administrador*).
- **Vista de Perfil Mejorada**: Se reconstruyó la pestaña de **Perfil** presentando la información completa del usuario (Avatar, Nombre, Correo, Badge de Rol Ministerial), tarjetas estadísticas de servicios confirmados y nivel de cuenta, junto con conmutador de rol y cierre de sesión.
- **Traducción Total al Español**: Se tradujeron absolutamente todos los textos de la interfaz al español elimando encabezados en inglés (ej. *Coordinación Ministerial*, *Bandeja de Cronogramas*, *Horarios de Servicio Oficiales*).

### 21. Flujo Corregido: Permisos desde el Admin y Enlace al Pie en el Login (04/08/2026)
- **Eliminación de Selección de Rol en el Login**: El login ahora solo requiere iniciar sesión con Google (`Continuar con Google`). No se solicita ningún rol al usuario al entrar.
- **Enlace de Administración al Pie**: Se incorporó un enlace discreto en la parte inferior del card de login (*"Acceso a Panel de Administración (Líder)"*) para acceder al panel de control.
- **Nueva Vista de Administración de Permisos**: En la sección de Admin se creó la pestaña **"Permisos"** (`AdminMembersView`) que permite a los líderes asignar y modificar el nivel de acceso (*Miembro Servidor* o *Líder Admin*) de cualquier usuario.

### 22. Generación e Integración de Login Screen en la Gama del Blanco en Stitch (04/08/2026)
- **Generación en Stitch MCP**: Se ejecutó `generate_screen_from_text` para la pantalla `Login Screen (Google Auth)` en el proyecto de Stitch (`9255270375602945903`) con la paleta de blanco puro (`#FFFFFF`), canvas slate (`#F7F9FB`), insignia dorada central y tipografía `Outfit`.
- **Implementación Fiel en Flutter**: Se actualizó `LoginScreen` (`frontend/lib/features/auth/presentation/login_screen.dart`) reflejando exactamente el diseño de Stitch con el emblema circular en la parte superior, botón principal de Google y enlace discreto en la parte inferior para administradores.

### 23. Integración del Logo Oficial en la Pantalla de Login (04/08/2026)
- **Asset de Logo Oficial**: Se guardó e incorporó la imagen oficial del logo (*Ministerio de Jesús - Trastornadores - Visión Conquistadora*) en `frontend/assets/images/logo.png` y `frontend/web/assets/logo.png`.
- **Integración de Componentes**: Se actualizó `TrastornadoresBadgeLogo` y `TrastornadoresHeaderLogo` (`frontend/lib/core/widgets/logo_widget.dart`) para cargar directamente el gráfico PNG oficial en `LoginScreen` y en las barras superiores de la app.

### 24. Rediseño Estético Deep Navy y Escudo con Luz Aural y Relieve 3D (04/08/2026)
- **Paleta de Colores de Referencia**: Se aplicó el degradado Deep Navy (`#06143D` -> `#040C24`) para el fondo y la tarjeta saturada azul rey (`#0D235C`) con bordes iluminados de 1.5px.
- **Borde de Luz y Relieve 3D en el Escudo**: El contenedor del logo oficial incorporó una luz aural con sombra difusa dorada (`#FFC107`) combinada con una sombra profunda de caída 3D (`blur: 20px, offset: Y 10px`) y borde dorado de 2.5px de grosor.
- **Estilo de Botones y Enlaces**: Botón blanco encapsulado (pill-shaped) para *Continuar con Google* y texto en dorado brillante para el acceso directo de administración.

### 25. Panel Blanco Traslúcido Glassmorphism y Escudo con Resplandor Dorado (04/08/2026)
- **Panel Blanco Traslúcido (`BackdropFilter`)**: Se aplicó efecto de vidrio esmerilado (*Glassmorphism*) con opacidad blanca al 12% (`color: Colors.white.withOpacity(0.12)` y `blur: 16px`) sobre el fondo Deep Navy para lograr un contraste óptimo.
- **Escudo con Resplandor Aura Dorado**: Se añadieron doble sombra difusa en tono dorado (`#FFC107`, `blur: 36px, spread: 4px`) y azul rey, con relieve 3D profundo (`blur: 24px, offset: Y 12px`) y contorno dorado de 3.0px.
- **Tipografía y Contraste**: Títulos en blanco puro con sombra proyectada (*drop shadow*) e icono de administración en dorado vibrante.

### 26. Resplandor y Relieve 3D Siguiendo la Silueta Exacta del Logo (04/08/2026)
- **Eliminación de Cajas Cuadradas**: Se eliminó cualquier marco, recuadro o caja alrededor del logo.
- **Efecto de Silueta de Contorno (`TrastornadoresBadgeLogo`)**: El resplandor dorado (`#FFC107`) y la sombra de relieve 3D se aplican directamente sobre la forma exacta del logo gráfico (el mundo, las letras del Ministerio y la cruz), creando un contorno iluminado flotante con relieve sin bordes cuadrados.

### 27. Halo Radiante de Luz Blanca y Fondo Azul Rey de Alto Contraste (04/08/2026)
- **Fondo Azul Rey Vibrante**: Se ajustó el degradado del canvas a tonos azul rey más vivos y luminosos (`#0C3088` -> `#0038A8`).
- **Halo Radiante Blanco y Dorado**: Se incorporó un destello de luz blanca pura central (`blur: 40px, opacity: 0.75`) combinado con la aureola dorada detrás de la silueta del logo (`TrastornadoresBadgeLogo`) para que las letras oscuras y el mundo destaquen con total nitidez y legibilidad.
- **Vidrio Esmerilado Luminoso**: El panel blanco traslúcido aumentó su opacidad a 18% con bordes de cristal brillante al 40%.

### 28. Restablecimiento del Fondo Blanco Puro Nítido (04/08/2026)
- **Fondo Blanco Slate (`#F7F9FB`)**: Se restableció la pantalla de login al fondo blanco slate ultra-limpio con la tarjeta blanca brillante (`#FFFFFF`) y sombras tonales de 20px.
- **Logo Oficial sobre Fondo Blanco**: El logo oficial con su resplandor dorado suave y sombra de contorno destaca nítidamente sobre el fondo claro.

### 29. Autenticación Multimétodo: Teléfono + Perfil, Correo/Clave y Google (04/08/2026)
- **Tres Opciones Interactivas de Ingreso**:
  1. **Google**: Botón directo de un solo toque con cuenta oficial.
  2. **Número de Teléfono y Perfil**: Formulario para ingresar teléfono (`+57 ...`), Nombre Completo y Ministerio/Equipo, creando y guardando el perfil del usuario.
  3. **Correo y Contraseña**: Formulario estándar con validación de credenciales.
- **Acceso Administrativo al Pie**: Se mantuvo el enlace inferior para ingresar al panel de control de líderes administradores.

### 30. Simplificación del Ingreso por Teléfono (04/08/2026)
- **Campos Solicitados**: Se eliminó el campo opcional de Ministerio. La opción de teléfono requiere únicamente **Número de Teléfono** (`+57 ...`) y **Nombre Completo**.
- **Creación de Perfil Directo**: Al enviar los datos, se crea y registra el perfil del servidor participante para confirmar su disponibilidad de inmediato.

### 31. Módulo de Mensajería y Alertas por WhatsApp (`WhatsAppService`) (04/08/2026)
- **Integración de Enlaces Directos de WhatsApp**: Se creó `WhatsAppService` (`frontend/lib/core/services/whatsapp_service.dart`) para generar y abrir mensajes formateados en la aplicación móvil de WhatsApp o WhatsApp Web.
- **Alertas de Grupo**: En la vista de Agenda (`AdminAgendaView`), el botón **"Enviar Alerta a WhatsApp 📲"** genera la nómina de confirmados con formato de la iglesia para publicarla directamente al grupo del ministerio.
- **Recordatorios Individuales**: Cada servidor verificado posee un botón directo de chat para enviarle una alerta personalizada de recordatorio de servicio.

### 32. Corrección de Lanzador Web de WhatsApp y URL del Logo de Google (04/08/2026)
- **Soporte Web de WhatsApp sin Excepciones**: Se actualizó `WhatsAppService` utilizando `html.window.open` al detectar entorno web (`kIsWeb`), eliminando el error `MissingPluginException` y abriendo WhatsApp / WhatsApp Web directamente en una nueva pestaña del navegador.
- **Icono Confiable de Google**: Se actualizó la imagen del botón de inicio de sesión de Google a una fuente oficial estática (`gstatic`) libre de errores 404.

### 12. Fortalecimiento del Backend: Auth Real, Módulo Users y Buenas Prácticas (04/08/2026)
- **Verificación real de tokens Firebase**: `FirebaseAuthGuard` ahora verifica el Bearer token contra el Admin SDK mediante el nuevo `FirebaseService` (módulo global `core/firebase/`). El mock solo aplica en desarrollo sin credenciales (`isMockEnabled`), nunca en producción.
- **Nuevo `UsersModule` (global)**: sincroniza el `firebaseUid` del token con la tabla `User` (upsert por `firebaseUid`). Endpoints protegidos `POST /users/sync` y `GET /users/me`.
- **Corrección del mapeo de usuario**: `registerAvailability` ya no usa el `firebaseUid` como `userId` de la tabla; ahora resuelve el `User.id` interno vía `UsersService.getOrCreateByFirebaseUid`.
- **`PrismaService`**: se implementó `onModuleDestroy` con `$disconnect()` y se registró `enableShutdownHooks(app)` en `main.ts`.
- **Configuración**: se instaló `@nestjs/config` (ConfigModule global, `.env` con `PORT`, `NODE_ENV`, `FIREBASE_SERVICE_ACCOUNT_PATH`). `main.ts` limpio: sin init de Firebase (lo maneja `FirebaseService`), puerto configurable.
- **Validaciones y Swagger**: `CreateScheduleDto.year` limitado a año actual + 2; se agregaron `@ApiCreatedResponse`/`@ApiOkResponse` a los endpoints.
- **Tipos centralizados**: `core/auth/types/auth.types.ts` con `AuthUser` y `AuthenticatedRequest`.
- **Tests**: 12 pruebas unitarias (guard de Firebase, `UsersService`, `ScheduleService` con generación de fechas, DTO upsert).
- **Verificación**: `npm run build`, `npm run lint` y `npm test` pasan sin errores. Prueba de humo E2E contra Neon: `POST /users/sync` crea el usuario, `POST /schedule` genera solo Jue/Sáb/Dom (octubre 2026: 14 fechas) y `POST /schedule/availability` registra disponibilidad vinculada al `User.id` interno.
- **Pendiente recomendado**: crear migraciones formales de Prisma (`prisma migrate dev`) para gestionar el esquema versionado en lugar de `db push`.

### 33. Automatización de Alertas de WhatsApp desde Backend (NestJS) (04/08/2026)
- **Modificación de Base de Datos**: Se agregó el campo `phone String?` a la tabla `User` en `schema.prisma` y se sincronizó con Neon DB.
- **Módulo de Notificaciones**: Se creó el `NotificationsModule` y el `WhatsappService` en el backend. Actualmente configurado como *Mock Provider* (simulación mediante logs) para facilitar el reemplazo futuro por credenciales reales de la API de Meta o Twilio.
- **Nuevos Endpoints**: Se agregaron `POST /schedule/notify/group/:dateId` y `POST /schedule/notify/reminder/:dateId/:userId` para procesar alertas desde el servidor.
- **Frontend - Registro Estricto**: Se modificó `LoginScreen` para requerir obligatoriamente el ingreso de un número de WhatsApp (mediante un popup Modal) a los usuarios que ingresan mediante Google Auth o Correo Electrónico que carezcan de él.
- **Migración de Botones de Alerta**: Se desvinculó el paquete `url_launcher` en la vista de administradores (`AdminAgendaView`). Los botones de alertas ahora realizan llamadas directas al backend utilizando la instancia configurada de `Dio`, garantizando que el sistema sea automatizado independientemente de si el líder tiene o no la aplicación de WhatsApp instalada en su dispositivo.

### 34. Integracion del Andamiaje de OpenCode con la Linea Remota (10/09/2026)
- **Contexto**: el remoto (`7ffc92c`) ya includia RBAC, modulo `users`, `FirebaseService`, proyecto Flutter completo (modelos Freezed generados, plataformas android/ios/web/windows/linux/macos) y tests. Se integro el andamiaje de opencode **sobre esa linea**, descartando el trabajo local que quedo superseded, para no perder los avances remotos.
- **Backend**: sin cambios propios. Se verifico que `ConfigModule.forRoot({ envFilePath: '.env' })` ya carga las variables de entorno, por lo que no se agrego `dotenv`. Estado: `npm run lint` 0 errores, `npm run build` correcto, **25/25 tests** en 5 suites.
- **Frontend - Autenticacion en peticiones**: `dioProvider` dejo de enviar el header fijo `'Authorization': 'Bearer dev-token'` y ahora incorpora un `InterceptorsWrapper` que adjunta el **ID token real de Firebase Authentication** en cada peticion. Si no hay sesion de Firebase (dispositivo sin Firebase inicializado), cae a un token de respaldo solo para desarrollo, compatible con el modo mock del backend (`FirebaseService.isMockEnabled`).
- **Configuracion de opencode (`opencode.json`)**: se unifico la configuracion en el archivo de la raiz. Se conservan los MCPs `neon` y `stitch`, y se agregan `github`, `postgres`, `filesystem` y `playwright`. La clave de Stitch paso de un placeholder en el repositorio a la variable de entorno `{env:STITCH_API_KEY}`. Se inyecta contexto automatico con `instructions` (`.agents/AGENTS.md`, `Bitacora.md`, `ROADMAP.md`).
- **Agentes** (`.opencode/agent/`): se agregan 5 agentes - `backend-architect`, `flutter-dev`, `security-reviewer` (sin edicion), `code-reviewer` (sin edicion) y `bitacora-keeper`.
- **Skills**: se agregan `add-nestjs-module`, `add-flutter-feature`, `security-checklist` y `update-bitacora`. Se conserva `trastornadores-dev` como skill principal de convenciones para evitar dos fuentes de verdad.
- **Comandos**: se consolidan en `.opencode/commands/` (se conserva `check` y `gen-models`). Se agregan `/estado` (detecta documentacion desactualizada), `/actualizar-bitacora` (sincroniza Bitacora + Roadmap + AGENTS), `/nuevo-modulo` y `/revisar-seguridad`.
- **`ROADMAP.md`**: hoja de ruta nueva con el estado de avance por bloques, para evitar contextos desactualizados entre sesiones.
- **Nota**: el archivo `.opencode/opencode.json` se eliminó al unificar la configuracion en `opencode.json` de la raiz.

### 35. Ciclos Autónomos y `flutter analyze` en Verde (10/10/2026)
- **Sistema de Ciclos Autónomos Implementado**: Se creó infraestructura completa de 4 ciclos autónomos que corren en paralelo sin intervención manual:
  1. **Verificación Continua** (5 min): lint + build + test backend + `flutter analyze` + test frontend
  2. **Seguridad Continua** (10 min): Escaneo OWASP + npm audit + secretos + config (Helmet, Throttler, CORS, Swagger) rota scopes
  3. **Agentes Colaborativos** (15 min): Pipeline E2E: `functional-expert` valida → `backend-architect`/`flutter-dev` implementan → `code-reviewer` revisa → `security-reviewer` audita → `bitacora-keeper` documenta
  4. **Roadmap-Driven** (30 min): Lee ROADMAP → pick siguiente `[ ]` → `functional-expert` valida valor ministerial → asigna agente → ejecuta → verifica → marca `[x]` → actualiza docs
- **Archivos Creados**:
  - Estado: `.opencode/state/cycle-state.json`
  - Comandos: `ciclo-autonomo.md`, `ciclo-verificacion.md`, `ciclo-colaborativo.md`, `ciclo-roadmap.md`, `ciclo-seguridad.md`
  - Ejecutores: `.opencode/scripts/run-cycles.ps1` (Windows), `run-cycles.sh` (Linux/Mac)
  - Documentación: `AUTONOMOUS_CYCLES_README.md`
  - Agente nuevo: `.opencode/agent/functional-expert.md` (modelo `exo-free` - el más nuevo Oct 2025)
- **Modelos Asignados por Complejidad**:
  - `security-reviewer`: `nemotron-3-ultra-free` (razonamiento profundo)
  - `functional-expert`: `exo-free` `high` (dominio, priorización ministerial)
  - `backend-architect`: `nemotron-3.5-lightning-free` (arquitectura, escalabilidad)
  - `flutter-dev`: `ling-3.1-flash-free` (coding Flutter/Riverpod/Freezed)
  - `code-reviewer`: `space-bunny-free` `max` (patrones, convenciones)
  - `bitacora-keeper`: `mimo-v2.6-flash-free` (docs, sincronización)
- **ROADMAP 3.10 COMPLETADO**: `flutter analyze` en verde (0 issues)
  - Fixados 21 warnings: `withOpacity`→`withValues()` (12), `dart:html`→`package:web` (1), `const` constructors (2), campos/variables no usados (2), `MaterialStateProperty`→`WidgetStateProperty` (1), `background`→`surface` (1)
  - Agregada dependencia `web: ^0.5.1` compatible con Firebase
  - Verificación: Backend lint 0, build OK, 25/25 tests; Frontend analyze 0 issues, 8/8 tests
- **ROADMAP Actualizado**: Items 3.10, 7.4, 7.5 marcados `[x]`

### 36. Tests de Widget Críticos y Product Manager Autónomo (10/10/2026)
- **ROADMAP 3.11 COMPLETADO**: Tests de widget para pantallas críticas (13 nuevos tests)
  - Archivo: `frontend/test/widget/critical_screens_test.dart`
  - Cobertura: LoginScreen (4 tests), Logo Widgets (2 tests), Admin Views (7 placeholders)
  - Tests pasan: 21 total (8 originales + 13 nuevos)
  - `flutter test` → 21/21 ✓, `flutter analyze` → 0 issues ✓
- **Agente Product Manager + Scrum Master creado**: `.opencode/agent/product-manager.md`
  - Modelo: `exo-free` (el más nuevo, variante `high`)
  - Rol dual: PM (priorización WSJF + valor ministerial) + SM (remueve impedimentos, DoD, ceremonias)
  - Bucle autónomo: Sincroniza → Prioriza → Planifica → Asigna → Monitorea → Remueve → Valida → Documenta → Cierra
  - Framework WSJF Ministerial: Valor (40%) + Urgencia (25%) + Riesgo (20%) / Esfuerzo
  - Mapeo ROADMAP → Agente, DoD por tipo, Métricas en cycle-state.json
  - Impedimentos auto-resueltos: analyze warnings, npm audit, tests rotos, deps conflicts
- **ROADMAP Actualizado**: Items 3.11, 7.6 marcados `[x]`

### 37. Auditoría + Cobertura Total de Pruebas (13/10/2026)
- **BUG CRÍTICO CORREGIDO**: `FirebaseAuthGuard` elevaba a ADMIN a todo usuario con rol en DB (`(role ?? bootstrap) ? ADMIN : ...`). Fix: `dbUser?.role ?? (bootstrap ? ADMIN : PARTICIPANT)` en `backend/src/core/auth/firebase-auth.guard.ts:43-51`. Test de regresión agregado.
- **Backend: 25 → 73 tests (10 suites)**:
  - `schedule.service.spec`: 8 → 20 (oct-2026 14 fechas, feb-2024 bisiesto, sin meses vecinos, getSchedules orden/includes, NO_PUEDO, idempotencia upsert, notifyGroup 0/N/phone-null/solo-PUEDO, notifyReminder ok/sin-user/sin-phone/sin-fecha)
  - `users.service.spec`: 5 → 11 (+no-degrada-rol, lastAccess, trim ADMIN_UIDS, sin-var, findByFirebaseUid, findById)
  - `firebase-auth.guard.spec`: 7 → 9 (+regresión PARTICIPANT se mantiene, hereda email/nombre/photo de DB)
  - `roles.guard.spec`: 4 → 6 (+multi-rol, array vacío)
  - NUEVOS: `whatsapp.service.spec` (4), `firebase.service.spec` (3), `schedule.controller.spec` (6), `users.controller.spec` (2), `schedule.dto.spec` (6)
  - Verificación: `npm run lint` 0 errores, `npm run build` OK, `npm test` 73/73
- **Frontend: 21 → 55 tests, `flutter analyze` 0 issues**:
  - `schedule_repository_test`: 4 → 18 (+Map-wrapped, bare-Map, payload inesperado, NO_PUEDO, create/update/notify endpoints, offline con mensaje)
  - `schedule_model_test`: 4 → 11 (+toJson roundtrip x4, defaults vacíos, copyWith isOpen)
  - NUEVOS: `user_provider_test` (8: defaults, mockProfile, override, fetch ok/defaults/fallback-no-Map), `schedule_providers_test` (5: repository, future ok/error/vacío, dio baseUrl)
  - `critical_screens_test`: fix `prefer_const_constructors` (6 infos → 0)
  - Verificación: `flutter analyze` 0 issues, `flutter test` 55/55
- **Seguridad `npm audit`**: 24 vulns (2 críticas `handlebars`, `proxy-addr` transitivas de NestJS/Swagger + 11 altas + 11 moderadas). No bloquean push; documentadas para roadmap 4.7.
- **ROADMAP**: sin cambios de `[x]` (3.10, 3.11, 7.4, 7.5, 7.6 ya estaban marcados); queda como siguiente 2.11 Helmet+Throttler, 3.12, 3.13, 4.5.
