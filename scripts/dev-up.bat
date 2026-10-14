@echo off
REM Levanta el stack completo: DB + backend + frontend web
cd /d %~dp0
docker compose up -d db
cd backend
if not exist .env (
  echo [dev-up] Creando backend/.env desde .env.example...
  copy .env.example .env
)
call npm install
call npx prisma generate
start "Trastornadores Backend" cmd /k "npm run start:dev"
cd ..\frontend
call flutter pub get
start "Trastornadores Frontend" cmd /k "flutter run -d chrome"
echo Stack levantado: backend http://localhost:3000, frontend web en Chrome.
