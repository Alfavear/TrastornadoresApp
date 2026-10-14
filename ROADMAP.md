# Roadmap TrastornadoresApp

Hoja de ruta del proyecto. Cada ítem marca su estado: `[ ]` pendiente, `[~]` en curso, `[x]` completado.

> **Regla de oro:** este archivo debe reflejar el estado **real** del código. Actualízalo con `/actualizar-bitacora` al cerrar cada sesión. Si el código y este documento discrepan, el código gana: corrige el documento.

## Última revisión
- Fecha: 2026-10-09
- Base: `origin/main` (7ffc92c) + andamiaje de opencode

## 1. Infraestructura
- [ ] 1.1 Levantar stack completo con un solo comando (docker compose + scripts)
- [ ] 1.2 `.env.example` documentado por ambiente (dev/staging/prod)
- [x] 1.3 Dockerfile del backend
- [x] 1.4 Pipeline CI (lint + build + test) en GitHub Actions
- [ ] 1.5 Estrategia de despliegue del backend

## 2. Backend NestJS
- [x] 2.1 Arquitectura base + módulos (`core`, `modules`)
- [x] 2.2 Prisma + PostgreSQL + esquema con `UserRole`
- [x] 2.3 `FirebaseService` (Admin SDK + modo mock controlable)
- [x] 2.4 `FirebaseAuthGuard` + tests
- [x] 2.5 RBAC: `roles.guard` + `@Roles` + tests
- [x] 2.6 Módulo `users` (sync Firebase, `/users/me`, bootstrap admin)
- [x] 2.7 Módulo `schedule` (Jue/Sáb/Dom) + tests
- [x] 2.8 Módulo `notifications` (WhatsApp, mock provider)
- [x] 2.9 DTOs con `class-validator` + Swagger
- [x] 2.10 Carga de `.env` vía `ConfigModule`
- [x] 2.11 Helmet + rate limiting (throttler)
- [x] 2.12 CORS restringido por ambiente
- [x] 2.13 Swagger protegido/deshabilitado en producción
- [x] 2.14 Logging estructurado
- [ ] 2.15 Migraciones de Prisma en CI (`prisma migrate deploy`)

## 3. Frontend Flutter
- [x] 3.1 Proyecto completo generado (android, ios, web, windows, linux, macos)
- [x] 3.2 Clean Architecture + Riverpod + GoRouter
- [x] 3.3 Modelos Freezed + JSON generados y versionados
- [x] 3.4 Login multimétodo (Google + correo) con WhatsApp obligatorio
- [x] 3.5 Participant: Mi Disponibilidad (chips, bulk actions, progreso)
- [x] 3.6 Admin: Calendario / Agenda / Matriz / Dashboard / Miembros / Cronogramas
- [x] 3.7 Notificaciones WhatsApp desde el backend
- [x] 3.8 Branding institucional (logo, colores, app bar)
- [x] 3.9 **Bearer token real de Firebase en cada petición** (interceptor en `dioProvider`)
- [x] 3.10 `flutter analyze` en verde
- [x] 3.11 Tests de widget para pantallas críticas
- [ ] 3.12 Build Android release (smoke)
- [x] 3.13 Manejo de sesión expirada (interceptor 401 → login)

## 4. Seguridad
- [x] 4.1 Guard con verificación real de token + fallback mock
- [x] 4.2 RBAC por rol (ADMIN / PARTICIPANT)
- [x] 4.3 Secretos fuera del repositorio (`.gitignore`)
- [x] 4.4 Validación global con `whitelist` + `transform`
- [x] 4.5 Bootstrap admin protegido (allowlist por UID/email)
- [ ] 4.6 Rotación de secretos documentada
- [ ] 4.7 Auditoría con `/revisar-seguridad` y cierre de hallazgos

## 5. OpenCode / Automatización
- [x] 5.1 Config unificada en `opencode.json` (raíz)
- [x] 5.2 6 MCPs: neon, stitch, github, postgres, filesystem, playwright
- [x] 5.3 Contexto automático (`instructions`: AGENTS, Bitacora, ROADMAP)
- [x] 5.4 5 agentes con modelo y permisos asignados
- [x] 5.5 5 skills (`trastornadores-dev` + 4 operativas)
- [x] 5.6 7 comandos (`/check`, `/gen-models`, `/bitacora`, `/estado`, `/actualizar-bitacora`, `/nuevo-modulo`, `/revisar-seguridad`)
- [ ] 5.7 Verificar que los MCPs inician (requiere `GITHUB_TOKEN` y `STITCH_API_KEY`)
- [ ] 5.8 Ajustar `model:` de los agentes si el proveedor no es Anthropic

## 6. Documentación
- [x] 6.1 `Bitacora.md` con historial
- [x] 6.2 `.agents/AGENTS.md` con reglas
- [x] 6.3 `OPENCODE.md` con configuración de opencode
- [x] 6.4 `ROADMAP.md` (este archivo)
- [x] 6.5 `README.md` raíz con setup rápido para el equipo
- [x] 6.6 Documentar modelo de datos y flujo de roles

## 7. Verificación
- [x] 7.1 Backend: lint 0 errores, build correcto
- [x] 7.2 Backend: 25/25 tests en 5 suites
- [x] 7.3 Modelos Freezed/JSON generados y versionados
- [x] 7.4 `flutter analyze` en verde
- [x] 7.5 `flutter test` en verde
- [x] 7.6 Smoke test: login → votar → ver en vista admin

## 8. Release MVP
- [x] 8.1 `.gitignore` auditado (sin secretos ni artefactos)
- [x] 8.2 Variables de entorno documentadas por ambiente
- [ ] 8.3 Backend desplegado
- [ ] 8.4 App Android firmada y distribuida
- [ ] 8.5 Plan de respaldos de la base de datos

## Reglas de mantenimiento
1. Al cerrar una tarea: marca `[x]` aquí y documenta en `Bitacora.md` (comando `/actualizar-bitacora`).
2. Al iniciar sesión: ejecuta `/estado` para recuperar contexto y detectar documentación desactualizada.
3. No marques `[x]` sin verificación ejecutada (`npm run build`, `npm test`, `flutter analyze`).