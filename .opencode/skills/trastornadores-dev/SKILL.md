---
name: trastornadores-dev
description: Desarrollo en el repositorio TrastornadoresApp (backend NestJS + frontend Flutter). ÚSALO al implementar, modificar o revisar código de este proyecto. Carga las convenciones, los archivos obligatorios (Bitacora.md, AGENTS.md, OPENCODE.md), las reglas de Clean Architecture e idioma, y los comandos de verificación.
---

# TrastornadoresApp - Desarrollo

Reglas y workflow para trabajar en el repositorio TrastornadoresApp. Léelo completo antes de tocar código.

## 1. Documentación obligatoria (leer antes de cualquier cambio)

- `Bitacora.md` (raíz): registro histórico exacto de lo implementado. **No asumir que algo existe: consultar aquí.**
- `.agents/AGENTS.md`: visión del proyecto, stack y reglas de código.
- `OPENCODE.md`: configuración de opencode (MCP Neon, comandos, skills).

## 2. Stack y arquitectura

- **Backend:** Node.js + NestJS + TypeScript estricto + PostgreSQL/Prisma.
  - Base de datos local en Docker (`docker-compose.yml`). El MCP de Neon gestiona la nube, no reemplaza el Docker local.
  - Autenticación: Firebase (Google Sign-In), rutas protegidas con `FirebaseAuthGuard`.
- **Frontend:** Flutter + Riverpod + GoRouter + Dio + Freezed.
- **Patrón:** Clean Architecture en ambos lados (core, domain, data, presentation).

## 3. Reglas de código

1. **No romper Clean Architecture:** mantener separados UI, lógica de negocio y repositorios.
2. **Backend:** todo endpoint fuertemente tipado con DTOs (`class-validator`) y documentado con Swagger (`@nestjs/swagger`).
3. **Flutter:** favorecer componentes sin estado (`StatelessWidget`) envueltos en `ConsumerWidget` de Riverpod.
4. **Idioma:** el código (variables, funciones) va en inglés; los textos de la UI y los comentarios/documentación en español.
5. **No agregar comentarios al código** salvo que documente decisiones no obvias.
6. **Secretos:** nunca exponer `firebase-service-account.json`, `google-services.json`, API keys ni commits de secretos (`.gitignore` ya los protege).

## 4. Orden de desarrollo de módulos

1. **Cronograma de Disponibilidad** (en desarrollo): fechas Jueves/Sábado/Domingo, roles Participante y Administrador.
2. Módulos futuros **NO implementar** hasta finalizar Cronograma: servidores, finanzas, asistencia, integrantes/ministerios, inventario.

## 5. Verificación (siempre al terminar una tarea)

- Backend: `npm run build`, `npm run lint`, `npm test` (workdir `backend`).
- Frontend: `flutter analyze`, `flutter test` (workdir `frontend`).
- Regenerar modelos Freezed/JSON: `dart run build_runner build --delete-conflicting-outputs` (workdir `frontend`).
- O usar los comandos de opencode: `/check`, `/gen-models`.

## 6. Estado actual relevante

- Backend: módulo Schedule completo (controller Swagger + service con generación de fechas + DTOs + upsert disponibilidad), Prisma con tablas User/Schedule/ScheduleDate/Availability y enum PUEDO/NO_PUEDO. Compila, lint y tests OK.
- Frontend: Login estilizado, ScheduleScreen participante (barra de progreso, botones masivos) y 4 vistas admin (Calendario, Agenda con export WhatsApp, Matriz, Dashboard). Modelos Freezed/JSON generados.
- Pendiente conocido: vincular frontend al backend real (baseUrl localhost, token en headers) y redirección por estado de auth en GoRouter.