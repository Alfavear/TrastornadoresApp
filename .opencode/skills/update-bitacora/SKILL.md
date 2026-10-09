---
name: update-bitacora
description: Cómo y cuándo actualizar Bitacora.md y AGENTS.md de TrastornadoresApp. Úsala al terminar un avance, corregir configuración o tomar una decisión técnica, o cuando el usuario pida actualizar la bitácora.
---

# Actualizar la Bitacora

`Bitacora.md` (raíz) es el registro histórico exacto de lo implementado. `.agents/AGENTS.md` es el contexto/reglas para agentes de IA.

## Cuándo
- Se completó una funcionalidad o corrección relevante.
- Cambios de arquitectura, stack, dependencias o configuración (env, CI, MCPs).
- Cuando el usuario lo pida.

## Cómo
1. Revisa el worktree real: `git status`, `git diff`, archivos modificados. **No inventes.**
2. Añade una sección nueva al final, numerada, con **fecha** en español:
   ```md
   ## Fecha: DD de Mes de AAAA

   ### N. Título del bloque
   - Cambio concreto (qué se hizo).
   - Decisión de diseño (por qué).
   - Comandos de verificación ejecutados y su resultado.
   ```
3. Nunca borres entradas históricas; solo agrega o corrige.
4. Si cambian arquitectura/stack/reglas, actualiza también `.agents/AGENTS.md`.
5. Termina con un resumen de lo documentado.
