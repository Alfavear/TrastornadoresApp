---
name: security-checklist
description: Checklist de seguridad para el backend NestJS y el frontend Flutter de TrastornadoresApp (auth, secretos, validación, OWASP). Úsala en revisiones de seguridad o antes de desplegar.
---

# Checklist de seguridad

## Autenticación y autorización
- [ ] `FirebaseAuthGuard` verifica tokens reales (`verifyIdToken`). `FIREBASE_AUTH_MOCK` debe ser `false` en producción.
- [ ] Autorización por rol implementada para endpoints de administrador.
- [ ] El `userId`/rol nunca se toma del cliente; sale del token verificado.

## Secretos
- [ ] `.env`, `firebase-service-account.json`, `google-services.json` en `.gitignore` y fuera del historial de git.
- [ ] Secretos referenciados con `{env:VAR}`, no hardcodeados.
- [ ] Rotación documentada si un secreto se expone.

## Entradas y datos
- [ ] `ValidationPipe({ whitelist: true, transform: true })` global.
- [ ] DTOs con `class-validator` en todos los endpoints.
- [ ] Prisma parametriza queries (sin SQL crudo concatenado).

## Transporte y exposición
- [ ] CORS restringido en producción (no `enableCors()` abierto).
- [ ] Swagger (`/api/docs`) deshabilitado o protegido en producción.
- [ ] Rate limiting y headers de seguridad (`helmet`).
- [ ] HTTPS obligatorio.

## Dependencias
- [ ] `npm audit` sin vulnerabilidades altas/críticas.
- [ ] Versiones fijadas / lockfiles versionados.

## Frontend
- [ ] Tokens en tránsito solo por HTTPS.
- [ ] Errores no filtran detalles internos al usuario.

Reporta cada hallazgo con severidad y `archivo:línea`.
