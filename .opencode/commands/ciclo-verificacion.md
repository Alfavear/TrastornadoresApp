---
description: Ciclo de verificación continua. Ejecuta lint, build, tests de backend y frontend. Reporta estado y sugiere fixes.
agent: backend-architect
---

# Ciclo: Verificación Continua

Ejecuta la suite completa de verificación de calidad. Diseñado para correr cada 5 min en background.

## Pasos (Backend → Frontend)

### Backend (backend-architect)
```bash
cd backend
npm run lint      # 0 errores esperados
npm run build     # Compila sin errores
npm test          # 25/25 tests pasan
```

### Frontend (flutter-dev)
```bash
cd frontend
flutter analyze   # 0 issues (meta: verde)
flutter test      # 8/8 tests pasan
```

## Criterios de Éxito
- ✅ Backend: lint=0, build=ok, tests=25/25
- ✅ Frontend: analyze=0 issues, tests=8/8
- ⚠️ Frontend actual: 21 warnings (deprecations) → **objetivo: 0**

## Manejo de Fallos
1. Si lint/build falla → `backend-architect` intenta fix automático (formato, imports, tipos)
2. Si tests fallan → reporta suite/fallo, NO fixea (requiere análisis)
3. Si `flutter analyze` > 0 → `flutter-dev` fixea warnings triviales (deprecations, const, unused)
4. 3 fallos consecutivos → alerta en log, pausa ciclo, notifica

## Estado
- Lee/escribe: `.opencode/state/cycle-state.json` → `cycles.continuous-verification`
- Log: `.opencode/state/cycle-verificacion-<ISO8601>.log`

## Ejecución Manual
```
/ciclo-autonomo verificacion ejecutar-una
```