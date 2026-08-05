---
description: Verifica todo el proyecto (build + lint + tests del backend y analyze del frontend)
agent: build
---

Ejecuta la verificación completa del proyecto:

- Backend: `npm run build`, luego `npm run lint` y `npm test` (en el directorio `backend`).
- Frontend: `flutter analyze` (en el directorio `frontend`).

Corrige los errores encontrados y reporta el resultado en español.