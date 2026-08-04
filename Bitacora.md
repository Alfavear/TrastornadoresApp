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
