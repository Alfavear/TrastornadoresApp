# Ciclos Autónomos - TrastornadoresApp

Sistema de automatización continua donde **6 agentes especializados** trabajan en **4 ciclos paralelos** sin intervención manual, avanzando el proyecto 24/7.

---

## 🏗️ Arquitectura de Ciclos

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORQUESTADOR: /ciclo-autonomo                  │
│                     (run-cycles.ps1 / run-cycles.sh)             │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  VERIFICACIÓN    │ │   SEGURIDAD      │ │  COLABORATIVO    │
│  (cada 5 min)    │ │   (cada 10 min)  │ │   (cada 15 min)  │
│                  │ │                  │ │                  │
│ • lint + build   │ │ • OWASP scan     │ │ 1. functional-   │
│   + test backend │ │ • Secretos git   │ │    expert valida │
│ • flutter analyze│ │ • Deps audit     │ │ 2. backend-arch  │
│   + test front   │ │ • CORS/Helmet/   │ │    / flutter-dev │
│                  │ │   Throttler      │ │ 3. code-reviewer │
│ Agentes:         │ │ • Swagger/RBAC   │ │ 4. security-rev  │
│ • backend-arch   │ │                  │ │ 5. bitacora-kpr  │
│ • flutter-dev    │ │ Agente:          │ │                  │
│                  │ │ • security-rev   │ │ Pipeline E2E     │
└──────────────────┘ └──────────────────┘ └──────────────────┘
          │                    │                    │
          └────────────────────┴────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │      ROADMAP-DRIVEN    │
              │      (cada 30 min)     │
              │                        │
              │ • Lee ROADMAP.md       │
              │ • Pick siguiente [ ]   │
              │ • functional-expert    │
              │   valida valor         │
              │ • Asigna agente        │
              │ • Ejecuta → Verifica   │
              │ • Marca [x] + docs     │
              │                        │
              │ Agentes: todos         │
              └────────────────────────┘
```

---

## 🤖 Agentes y Modelos Asignados

| Agente | Modelo (OpenCode Zen) | Rol en Ciclos |
|--------|----------------------|---------------|
| `security-reviewer` | `nemotron-3-ultra-free` | Auditoría OWASP, secretos, config — **Ciclo Seguridad + Colaborativo** |
| `functional-expert` | `exo-free` (más nuevo, `high`) | Validación valor ministerial — **Ciclo Colaborativo + Roadmap** |
| `backend-architect` | `nemotron-3.5-lightning-free` | Implementación backend, remediación seguridad — **Todos los ciclos** |
| `flutter-dev` | `ling-3.1-flash-free` | Implementación frontend, fix warnings — **Ciclo Verificación + Colaborativo + Roadmap** |
| `code-reviewer` | `space-bunny-free` (`max`) | Convenciones, Clean Arch, tests — **Ciclo Colaborativo + Roadmap** |
| `bitacora-keeper` | `mimo-v2.6-flash-free` | Documentación, ROADMAP sync — **Todos los ciclos** |

---

## 🚀 Inicio Rápido

### PowerShell (Windows)
```powershell
# Ejecutar una iteración de todos los ciclos (foreground)
.\.opencode\scripts\run-cycles.ps1 todos ejecutar-una

# Iniciar todos los ciclos en background (loop infinito)
.\.opencode\scripts\run-cycles.ps1 todos iniciar

# Ver estado
.\.opencode\scripts\run-cycles.ps1 todos estado

# Parar
.\.opencode\scripts\run-cycles.ps1 todos parar

# Reset estado
.\.opencode\scripts\run-cycles.ps1 todos reset
```

### Bash (Linux/Mac/WSL)
```bash
chmod +x .opencode/scripts/run-cycles.sh

# Ejecutar una iteración
./.opencode/scripts/run-cycles.sh todos ejecutar-una

# Iniciar en background
./.opencode/scripts/run-cycles.sh todos iniciar &

# Ver estado
./.opencode/scripts/run-cycles.sh todos estado

# Parar
./.opencode/scripts/run-cycles.sh todos parar
```

### Via OpenCode Commands
```bash
# Desde opencode CLI
/ciclo-autonomo todos ejecutar-una
/ciclo-autonomo verificacion ejecutar-una
/ciclo-autonomo seguridad ejecutar-una
/ciclo-autonomo roadmap estado
```

---

## 📊 Estado Persistente

Archivo: `.opencode/state/cycle-state.json`

```json
{
  "cycles": {
    "continuous-verification": {
      "enabled": true,
      "intervalMinutes": 5,
      "lastRun": "2026-10-10T14:30:00Z",
      "lastResult": "OK",
      "consecutiveFailures": 0
    },
    "security-continuous": {
      "enabled": true,
      "intervalMinutes": 10,
      "lastRun": "2026-10-10T14:25:00Z",
      "lastResult": "CLEAN",
      "scanScope": "config"
    },
    "collaborative-agents": {
      "enabled": true,
      "intervalMinutes": 15,
      "currentPhase": "implementing",
      "workItem": { "criteria": "...", "timestamp": "..." }
    },
    "roadmap-driven": {
      "enabled": true,
      "intervalMinutes": 30,
      "nextItemIndex": 3,
      "completedItems": [
        { "item": "3.10 flutter analyze verde", "timestamp": "...", "result": "DONE" }
      ]
    }
  },
  "global": { "running": true, "pid": 12345, "startTime": "..." }
}
```

**Logs:** `.opencode/state/logs/cycle-<nombre>-<YYYYMMDD>.log`

---

## 🔄 Flujo de Trabajo Colaborativo (Pipeline E2E)

```
WORK ITEM (issue/PR/roadmap/TODO)
         │
         ▼
┌─────────────────────────────────────┐
│ 1. functional-expert (2 min)        │
│    ¿Valor ministerial real?         │
│    ¿Criterios de aceptación claros? │
│    → ACCEPTED / REJECTED            │
└─────────────────────────────────────┘
         │ ACCEPTED
         ▼
┌─────────────────────────────────────┐
│ 2. backend-architect / flutter-dev  │
│    (10 min)                         │
│    Implementa + tests + build OK    │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ 3. code-reviewer (3 min)            │
│    Convenciones, Clean Arch, tests  │
│    → APPROVED / CHANGES_REQUESTED   │
│    (max 2 vueltas review→impl)      │
└─────────────────────────────────────┘
         │ APPROVED
         ▼
┌─────────────────────────────────────┐
│ 4. security-reviewer (3 min)        │
│    Tabla: Crítico/Alta/Media/Baja   │
│    Si Crítico/Alta → backend-arch   │
│    remedia → re-verifica            │
└─────────────────────────────────────┘
         │ CLEAN
         ▼
┌─────────────────────────────────────┐
│ 5. bitacora-keeper (2 min)          │
│    Bitacora.md + ROADMAP.md [x]     │
│    AGENTS.md si cambia arquitectura │
└─────────────────────────────────────┘
         │
         ▼
      COMMIT + PUSH (opcional)
```

---

## 🎯 Roadmap-Driven: Items Actuales Pendientes

El ciclo `roadmap` procesa en orden de prioridad:

| # | Sección | Item | Agente | Estado |
|---|---------|------|--------|--------|
| 1 | 3. Frontend | 3.10 `flutter analyze` en verde | `flutter-dev` | 🎯 **PRÓXIMO** |
| 2 | 3. Frontend | 3.11 Tests widget pantallas críticas | `flutter-dev` | ⏳ |
| 3 | 2. Backend | 2.11 Helmet + rate limiting | `backend-architect` | ⏳ |
| 4 | 2. Backend | 2.12 CORS por ambiente | `backend-architect` | ⏳ |
| 5 | 2. Backend | 2.13 Swagger protegido prod | `backend-architect` | ⏳ |
| 6 | 4. Seguridad | 4.5 Bootstrap admin allowlist | `backend-architect` | ⏳ |
| 7 | 5. OpenCode | 5.7 Verificar MCPs | `bitacora-keeper` | ⏳ |
| 8 | 6. Docs | 6.5 README.md raíz | `bitacora-keeper` | ⏳ |

---

## 🛡️ Seguridad Continua: Checklist Automatizado

El ciclo `seguridad` rota scopes cada ejecución:

| Scope | Qué Escanea | Frecuencia |
|-------|-------------|------------|
| `full` | Todo + OWASP Top 10 | Cada 10 min |
| `deps` | `npm audit` + `flutter pub outdated` | Rotación |
| `secrets` | `.gitignore`, historial git, `.env*`, `firebase-*.json` | Rotación |
| `config` | CORS, Helmet, Throttler, Swagger, Logging | Rotación |
| `auth` | FirebaseAuthGuard, RBAC, mock mode | Rotación |

**Remediación automática:**
- **Crítico/Alta** → `backend-architect` fixea INMEDIATAMENTE
- **Media/Baja** → Reporta, agenda en roadmap

---

## ⚙️ Configuración

### Habilitar/Deshabilitar Ciclos
Edita `.opencode/state/cycle-state.json`:
```json
"cycles": {
  "continuous-verification": { "enabled": true, "intervalMinutes": 5 },
  "security-continuous": { "enabled": true, "intervalMinutes": 10 },
  "collaborative-agents": { "enabled": true, "intervalMinutes": 15 },
  "roadmap-driven": { "enabled": true, "intervalMinutes": 30 }
}
```

### Cambiar Intervalos
Modifica `intervalMinutes` en el state o pasa variable de entorno:
```bash
INTERVAL_VERIFICACION=3 INTERVAL_SEGURIDAD=5 ./.opencode/scripts/run-cycles.sh todos iniciar
```

### Agregar Work Items al Ciclo Colaborativo
1. **GitHub Issues** con label `autonomo`
2. **ROADMAP.md** items `[ ]`
3. **TODOs/FIXMEs** en código
4. **Warnings** `flutter analyze` no resueltos
5. **Hallazgos seguridad** no remediados

---

## 🔧 Integración CI/CD (GitHub Actions)

El sistema de ciclos **debe replicarse en CI** para gatear merges:

```yaml
# .github/workflows/autonomous-cycles.yml
name: Autonomous Cycles
on: [push, pull_request, schedule]
jobs:
  verification:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd backend && npm ci && npm run lint && npm run build && npm test
      - run: cd frontend && flutter analyze && flutter test
  
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
      - run: opencode run "security-reviewer: Escaneo full..."
```

---

## 📝 Comandos de Referencia Rápida

| Comando | Descripción |
|---------|-------------|
| `/ciclo-autonomo todos ejecutar-una` | Una pasada completa de los 4 ciclos |
| `/ciclo-autonomo verificacion ejecutar-una` | Solo lint/build/test/analyze |
| `/ciclo-autonomo seguridad ejecutar-una` | Solo auditoría seguridad |
| `/ciclo-autonomo colaborativo ejecutar-una` | Una iteración pipeline E2E |
| `/ciclo-autonomo roadmap ejecutar-una` | Procesa 1 item del ROADMAP |
| `/ciclo-autonomo todos estado` | Estado JSON de todos los ciclos |
| `/ciclo-autonomo todos reset` | Limpia estado y contadores |

---

## ⚠️ Consideraciones

1. **No hay daemon nativo en OpenCode** — los scripts `run-cycles.*` corren un `while true` loop. Para producción, usar systemd/supervisord/pm2.
2. **Rate limits de modelos gratuitos** — los modelos OpenCode Zen tienen límites. Los ciclos espacian requests (30s check interval).
3. **Estado en JSON** — no transaccional. Si se mata el proceso, `lastRun` puede quedar desactualizado (auto-corrección en siguiente iteración).
4. **Permisos de agentes** — `security-reviewer`, `code-reviewer`, `functional-expert` tienen `edit: deny`. Solo `backend-architect`, `flutter-dev`, `bitacora-keeper` editan.
5. **Secrets requeridos** — `GITHUB_TOKEN`, `STITCH_API_KEY` en env para MCPs. Sin ellos, ciclos que usan GitHub/Stitch fallarán.

---

## 🎯 Próximos Pasos Recomendados

1. **Ejecutar primera pasada:** `./.opencode/scripts/run-cycles.sh todos ejecutar-una`
2. **Verificar logs:** `cat .opencode/state/logs/cycle-*-$(date +%Y%m%d).log`
3. **Ajustar intervalos** según velocidad deseada
4. **Configurar systemd/pm2** para producción 24/7
5. **Replicar en GitHub Actions** para CI gate

---

*Generado automáticamente por el sistema de ciclos autónomos de TrastornadoresApp. Última actualización: 2026-10-10*