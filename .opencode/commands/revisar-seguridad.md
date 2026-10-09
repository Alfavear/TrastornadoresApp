---
description: Ejecuta una revisión de seguridad del backend y frontend contra la checklist del proyecto.
agent: security-reviewer
---

Realiza una auditoría de seguridad de TrastornadoresApp siguiendo la skill `security-checklist`.

Alcance: $ARGUMENTS (si está vacío, revisa todo el repositorio).

Revisa autenticación, secretos, validación de entradas, CORS/Swagger/headers, dependencias y manejo de errores. Entrega una tabla de hallazgos con severidad y `archivo:línea`, y un orden de remediación priorizado. No modifiques código.
