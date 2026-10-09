---
description: Actualiza Bitacora.md, AGENTS.md y ROADMAP.md para que reflejen el worktree real. Úsalo tras cada avance.
agent: bitacora-keeper
---

Revisa el estado real del repositorio (`git status`, `git diff`, archivos nuevos) y **sincroniza la documentación**:

1. **`Bitacora.md`** — añade una sección numerada con la fecha de hoy, en español, sin borrar entradas históricas (skill `update-bitacora`).
2. **`ROADMAP.md`** — marca `[x]` lo completado, ajusta `[~]` lo parcial y añade los ítems nuevos que surjan. Actualiza la línea "Última revisión".
3. **`.agents/AGENTS.md`** — solo si cambian arquitectura, stack o reglas.

**Instrucción obligatoria:** la documentación debe reflejar el **worktree real**, no lo que supones. Si detectas que un documento quedó desactualizado respecto al código, corrígelo en esta misma pasada.

Contexto adicional del usuario: $ARGUMENTS