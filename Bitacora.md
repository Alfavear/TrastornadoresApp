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
