---
description: Crea un nuevo módulo NestJS en el backend siguiendo las convenciones del proyecto.
agent: backend-architect
---

Crea un nuevo módulo NestJS llamado "$ARGUMENTS" siguiendo la skill `add-nestjs-module`.

Pasos:
1. Lee `.agents/AGENTS.md` y `Bitacora.md`.
2. Genera DTO(s), service, controller (con Swagger + `FirebaseAuthGuard`) y module en `backend/src/modules/<nombre>/`.
3. Regístralo en `app.module.ts`. Si requiere entidades, actualiza `prisma/schema.prisma` y genera la migración/cliente.
4. Ejecuta `npm run lint`, `npm run build` y `npm test`; informa el resultado.
5. Actualiza `Bitacora.md`.

El nombre del módulo es "$ARGUMENTS".
