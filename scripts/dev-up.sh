#!/usr/bin/env bash
# Levanta el stack completo: DB + backend + frontend web
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
docker compose up -d db
cd backend
[ -f .env ] || { echo "[dev-up] Creando backend/.env desde .env.example..."; cp .env.example .env; }
npm install
npx prisma generate
(npm run start:dev &) 
cd ../frontend
flutter pub get
flutter run -d chrome
