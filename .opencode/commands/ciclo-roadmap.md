---
description: Ciclo roadmap-driven. Lee ROADMAP.md, detecta siguiente item pendiente [ ], valida con functional-expert, asigna agente, ejecuta, marca [x], actualiza docs.
agent: bitacora-keeper
---

# Ciclo: Roadmap-Driven

Automatiza el avance del ROADMAP.md: **detecta → valida → ejecuta → verifica → documenta → marca [x]**.

## Algoritmo de Selección
Lee `ROADMAP.md` en orden y pick el **primer `[ ]`** que cumpla:
1. **Sección prioritaria** (orden: Infra → Backend → Frontend → Seguridad → OpenCode → Docs → Verificación → Release)
2. **Dependencias resueltas** (items previos en `[x]`)
3. **Agente disponible** (backend-architect / flutter-dev / security-reviewer)
4. **No bloqueado** (no requiere secretos externos no configurados)

## Flujo por Item

```
ROADMAP.md → nextItem()
    ↓
functional-expert: ¿Valor ministerial? ¿Factible ahora?
    ↓ NO → skip (documenta razón) → nextItem()
    ↓ SÍ
Asigna agente:
  - Backend (2.x) → backend-architect
  - Frontend (3.x) → flutter-dev
  - Seguridad (4.x) → security-reviewer + backend-architect
  - OpenCode (5.x) → bitacora-keeper
  - Docs (6.x) → bitacora-keeper
  - Verificación (7.x) → backend-architect + flutter-dev
  - Release (8.x) → backend-architect + flutter-dev
    ↓
Agente ejecuta: implementa + tests + verificación
    ↓
code-reviewer + security-reviewer (paralelo)
    ↓
bitacora-keeper: Documenta en Bitacora.md + actualiza ROADMAP.md ([ ] → [x])
    ↓
Verificación final: `/check` pasa
    ↓
Commit + push (si configurado)
    ↓
Siguiente item...
```

## Estado
- Lee/escribe: `.opencode/state/cycle-state.json` → `cycles.roadmap-driven`
- `nextItemIndex`: índice en array de items parseados de ROADMAP
- `completedItems`: array de `{ section, item, timestamp, agent, commit }`
- Log: `.opencode/state/cycle-roadmap-<ISO8601>.log`

## Items Actuales Pendientes (ROADMAP 2026-10-09)
| Prioridad | Sección | Item | Agente |
|-----------|---------|------|--------|
| 1 | 3. Frontend | 3.10 `flutter analyze` en verde | flutter-dev |
| 2 | 3. Frontend | 3.11 Tests widget pantallas críticas | flutter-dev |
| 3 | 2. Backend | 2.11 Helmet + rate limiting | backend-architect |
| 4 | 2. Backend | 2.12 CORS por ambiente | backend-architect |
| 5 | 2. Backend | 2.13 Swagger protegido prod | backend-architect |
| 6 | 4. Seguridad | 4.5 Bootstrap admin allowlist | backend-architect |
| 7 | 5. OpenCode | 5.7 Verificar MCPs | bitacora-keeper |
| 8 | 6. Docs | 6.5 README.md raíz | bitacora-keeper |

## Ejecución Manual
```
/ciclo-autonomo roadmap ejecutar-una
```

## Reglas
- **Un item a la vez** (secuencial, no paralelo)
- Si agente falla 2 veces → marca item `[~]` (en curso), pasa al siguiente, reintenta en siguiente ciclo
- `bitacora-keeper` actualiza ROADMAP.md **inmediatamente** tras verificación exitosa
- No avanza si `/check` falla