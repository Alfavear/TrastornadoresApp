# TrastornadoresApp

Plataforma del Ministerio de Jesús — Trastornadores (Visión Conquistadora) para coordinar disponibilidad de servidores en los servicios semanales (Jue 19:30, Sáb 18:00, Dom 09:00–14:00).

## Stack
- **Backend**: NestJS 11 + Prisma 6 + PostgreSQL + Firebase Auth + Swagger (`/api/docs` solo no-prod).
- **Frontend**: Flutter + Riverpod + GoRouter + Dio + Freezed.
- **Docs vivas**: `Bitacora.md`, `ROADMAP.md`, `docs/DATA_MODEL.md`, `AUTONOMOUS_CYCLES_README.md`.

## Setup rápido (5 min)

```bash
# 1. Clonar + backend
cd backend
cp .env.example .env   # ajustar DATABASE_URL, ADMIN_UIDS/ADMIN_EMAILS, CORS_ORIGINS
npm install
npx prisma generate
npm run build && npm test   # 90 tests

# 2. DB local (Docker) o Neon
# docker compose up -d db
npx prisma db push          # dev; prod usa `prisma migrate deploy`

# 3. Correr backend
npm run start:dev            # http://localhost:3000, docs en /api/docs

# 4. Frontend
cd ../frontend
flutter pub get
flutter analyze              # 0 issues
flutter test                 # 61 tests
flutter run -d chrome        # web; Android: flutter run
```

## Variables clave
Ver `backend/.env.example`. En prod definir: `DATABASE_URL`, `NODE_ENV=production`, `CORS_ORIGINS`, `ADMIN_UIDS`/`ADMIN_EMAILS`, `FIREBASE_SERVICE_ACCOUNT_PATH`. Nunca commitear `.env`, `firebase-service-account.json`, `google-services.json` (ver `.gitignore` auditado).

## Seguridad por defecto
Helmet + Throttler global (100 req/min; notify 10–20/min anti-spam), CORS por ambiente, Swagger apagado en prod, RBAC `ADMIN`/`PARTICIPANT`, bootstrap solo por allowlist, 401 frontend → `/login`.

## Estado
Ver `ROADMAP.md` (fuente de verdad) y `Bitacora.md` §37–40 para el último avance.
