---
description: Orquestador de ciclos autónomos. Ejecuta uno o todos los loops: verificación continua, agentes colaborativos, roadmap-driven, seguridad continua. Úsalo para iniciar/parar/monitorear la automatización.
agent: bitacora-keeper
---

# Comando: `/ciclo-autonomo` — Orquestador de Automatización

Ejecuta ciclos autónomos sin intervención manual. Cada ciclo invoca agentes especializados en bucle.

## Uso
```
/ciclo-autonomo [ciclo] [accion]
```

| Ciclo | Descripción | Intervalo |
|-------|-------------|-----------|
| `verificacion` | Lint + build + test backend + `flutter analyze` + test frontend | 5 min |
| `colaborativo` | Pipeline: functional-expert → backend-architect/flutter-dev → code-reviewer/security-reviewer → bitacora-keeper | 15 min |
| `roadmap` | Lee ROADMAP → pick siguiente `[ ]` → asigna agente → ejecuta → marca `[x]` → actualiza docs | 30 min |
| `seguridad` | OWASP + secretos + deps + CORS + rate limit + Swagger exposición | 10 min |
| `todos` | Ejecuta los 4 en secuencia (recomendado para inicio) | — |

| Acción | Descripción |
|--------|-------------|
| `iniciar` | Arranca el/los ciclo(s) en background |
| `parar` | Detiene el/los ciclo(s) |
| `estado` | Muestra estado actual de todos los ciclos |
| `ejecutar-una` | Ejecuta una iteración sola (foreground) |
| `reset` | Limpia estado y reinicia contadores |

## Estado Persistente
- Archivo: `.opencode/state/cycle-state.json`
- Rastrea: última ejecución, resultado, fallos consecutivos, fase actual, work item

## Agentes Involucrados por Ciclo

### 1. Verificación Continua (`verificacion`)
- `backend-architect`: `npm run lint && npm run build && npm test`
- `flutter-dev`: `flutter analyze && flutter test`

### 2. Agentes Colaborativos (`colaborativo`)
1. `functional-expert`: Valida/descarta work item, define criterios de aceptación
2. `backend-architect` / `flutter-dev`: Implementan (según tipo)
3. `code-reviewer`: Revisa convenciones, Clean Architecture
4. `security-reviewer`: Audita seguridad
5. `bitacora-keeper`: Documenta en Bitacora.md, actualiza ROADMAP.md

### 3. Roadmap-Driven (`roadmap`)
1. `bitacora-keeper`: Lee ROADMAP.md, detecta siguiente `[ ]` prioritario
2. `functional-expert`: Valida valor ministerial del item
3. Asigna a `backend-architect` o `flutter-dev` según módulo
4. Ejecuta verificación + revisión + documentación

### 4. Seguridad Continua (`seguridad`)
- `security-reviewer`: Escaneo completo checklist `.opencode/skills/security-checklist/SKILL.md`
- `backend-architect`: Remedia hallazgos Críticos/Alta automáticamente
- Re-verifica hasta 0 críticos

## Ejemplos
```
/ciclo-autonomo todos iniciar          # Arranca los 4 ciclos en background
/ciclo-autonomo verificacion ejecutar-una   # Una pasada de verificación ahora
/ciclo-autonomo roadmap estado              # Ve qué item sigue en roadmap
/ciclo-autonomo seguridad ejecutar-una      # Auditoría de seguridad ahora
/ciclo-autonomo parar                       # Detiene todo
```

## Salida
Cada ciclo genera log en `.opencode/state/cycle-<nombre>-<timestamp>.log` y actualiza `cycle-state.json`.