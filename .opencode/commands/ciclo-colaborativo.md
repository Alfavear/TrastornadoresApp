---
description: Ciclo de agentes colaborativos. Pipeline: functional-expert valida → backend-architect/flutter-dev implementan → code-reviewer/security-reviewer auditan → bitacora-keeper documenta.
agent: functional-expert
---

# Ciclo: Agentes Colaborativos

Pipeline end-to-end: **idea → validación → implementación → revisión → seguridad → documentación**.

## Fases del Pipeline

| Fase | Agente | Entrada | Salida | Timeout |
|------|--------|---------|--------|---------|
| 1. Validación | `functional-expert` | Work item (issue/PR/roadmap item) | `ACCEPTED` + criterios aceptación / `REJECTED` + razón | 2 min |
| 2. Implementación | `backend-architect` \| `flutter-dev` | Criterios + archivos afectados | Código + tests + build passing | 10 min |
| 3. Code Review | `code-reviewer` | `git diff` + archivos nuevos | `APPROVED` / `CHANGES_REQUESTED` + hallazgos | 3 min |
| 4. Seguridad | `security-reviewer` | Código nuevo + config | Hallazgos tabla (Crítico/Alta/Media/Baja) | 3 min |
| 5. Documentación | `bitacora-keeper` | Cambios reales + decisiones | Bitacora.md + ROADMAP.md + AGENTS.md actualizados | 2 min |

## Fuente de Work Items (orden de prioridad)
1. **Issues abiertos** en GitHub (label `autonomo`)
2. **Próximo `[ ]` en ROADMAP.md** (prioridad por sección)
3. **TODOs/FIXMEs** en código (`grep -r "TODO\|FIXME"`)
4. **Warnings `flutter analyze`** no resueltos
5. **Hallazgos seguridad** no remediados

## Flujo de Decisión
```
Work Item
    ↓
functional-expert: ¿Valor ministerial real? ¿Criterios claros?
    ↓ NO → REJECTED (documenta por qué) → FIN
    ↓ SÍ
backend-architect / flutter-dev: Implementa + tests
    ↓
code-reviewer: ¿Convenciones? ¿Clean Arch? ¿Tests?
    ↓ CHANGES_REQUESTED → devuelve a implementación (max 2 vueltas)
    ↓ APPROVED
security-reviewer: ¿Críticos/Alta?
    ↓ SÍ → backend-architect remedia → vuelve a seguridad
    ↓ NO
bitacora-keeper: Documenta avance real
    ↓
ROADMAP.md: Marca [x] si aplica
    ↓
FIN: Work item completado
```

## Estado
- Lee/escribe: `.opencode/state/cycle-state.json` → `cycles.collaborative-agents`
- `currentPhase`: `idle` | `validating` | `implementing` | `reviewing` | `securing` | `documenting`
- `workItem`: `{ source, title, description, assignee, criteria }`
- Log: `.opencode/state/cycle-colaborativo-<ISO8601>.log`

## Ejecución Manual
```
/ciclo-autonomo colaborativo ejecutar-una
```

## Control de Calidad
- Máximo 2 iteraciones review→implement por work item
- Si security-reviewer halla Crítico → bloquea merge, remedia obligatorio
- bitacora-keeper **solo documenta lo real** (git diff), no inventa