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
