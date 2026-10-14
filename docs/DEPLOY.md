# Estrategia de despliegue + respaldos + rotación de secretos

## 1.5 Estrategia de despliegue del backend
- **Artefacto**: imagen Docker `backend/Dockerfile` (multi-stage, non-root).
- **Destinos recomendados**: Render / Railway / Fly.io / VPS con Docker.
- **Pasos**:
  1. `docker build -t trastornadores-backend ./backend`
  2. Configurar env prod (`DATABASE_URL`, `NODE_ENV=production`, `CORS_ORIGINS`, `ADMIN_UIDS`/`ADMIN_EMAILS`, `FIREBASE_SERVICE_ACCOUNT_PATH` vía secreto montado, NO en imagen).
  3. `npx prisma migrate deploy` antes de levantar (ver CI job).
  4. Healthcheck `GET /` o `/api/docs` solo si `ENABLE_SWAGGER=true`.
- **Frontend**: `flutter build web --release` (hosting estático) + `flutter build appbundle --release` (Play Store, requiere keystore fuera del repo).

## 2.15 Migraciones en CI
- `prisma validate` siempre; `prisma migrate deploy` solo en `main` con secreto `DATABASE_URL` (ver `ci.yml`).
- Dev local sigue con `prisma db push`; antes del primer deploy generar baseline: `prisma migrate dev --name init`.

## 4.6 Rotación de secretos
- **Firebase service account**: generar nueva clave en Firebase Console → reemplazar secreto montado → redeploy → revocar anterior. Ventana < 24h.
- **`ADMIN_UIDS`/`ADMIN_EMAILS`**: editar env y redeploy (sin código).
- **`DATABASE_URL`**: rotar password en Neon → actualizar secreto → `prisma migrate deploy` verifica conexión.
- **Nunca** commitear: `.env`, `firebase-service-account.json`, `google-services.json` (ver `.gitignore` + §41).

## 8.5 Plan de respaldos DB
- Neon: PITR + snapshots automáticos (retención según plan); además `pg_dump` semanal a almacenamiento externo.
- Restauración: verificar en staging con `prisma migrate deploy` + smoke `GET /schedule`.
