---
description: Ciclo de seguridad continua. Escanea OWASP, secretos, dependencias, CORS, rate limiting, Swagger exposición. Remedia hallazgos Críticos/Alta automáticamente.
agent: security-reviewer
---

# Ciclo: Seguridad Continua

Auditoría automática contra checklist del proyecto (`.opencode/skills/security-checklist/SKILL.md`) + OWASP Top 10.

## Alcance del Escaneo (`scanScope`)

| Scope | Qué Incluye | Frecuencia |
|-------|-------------|------------|
| `full` | Todo abajo + OWASP completo | Cada 10 min (ciclo) / diario (CI) |
| `deps` | `npm audit` + `flutter pub outdated` | Cada ciclo |
| `secrets` | `.gitignore`, historial git, `.env*`, `firebase-*.json` | Cada ciclo |
| `config` | CORS, Helmet, throttler, Swagger, logging | Cada ciclo |
| `auth` | FirebaseAuthGuard, RBAC, mock mode, token handling | Cada ciclo |

## Checklist Ejecutable (security-checklist skill)

### Backend (NestJS)
- [ ] `Helmet` configurado (`contentSecurityPolicy`, `hsts`, `xssFilter`)
- [ ] `ThrottlerModule` (rate limit) global + por endpoint sensible
- [ ] `CORS` restrictivo por `NODE_ENV` (origin array, credentials)
- [ ] Swagger **deshabilitado en producción** (`NODE_ENV=production`)
- [ ] `ValidationPipe` global: `whitelist: true`, `transform: true`, `forbidNonWhitelisted: true`
- [ ] `FirebaseAuthGuard`: verifica token real, **mock SOLO en dev** (`isMockEnabled`)
- [ ] RBAC: `RolesGuard` + `@Roles()` en todos los endpoints admin
- [ ] Secretos: `.env`, `firebase-service-account.json` en `.gitignore` + no en historial
- [ ] `npm audit` → 0 vulnerabilidades `critical`/`high`
- [ ] Logging estructurado (pino/winston) + no loggea tokens/PII
- [ ] Prisma: prepared statements, no SQL crudo, migraciones versionadas

### Frontend (Flutter)
- [ ] Tokens en tránsito: `dioProvider` inyecta Bearer real, **nunca hardcoded**
- [ ] Almacenamiento seguro: `flutter_secure_storage` para tokens/refresh
- [ ] Manejo 401 → logout + redirect login (interceptor)
- [ ] `flutter analyze` → 0 issues (incluye security warnings)
- [ ] No `http` plano en producción (solo `https`)
- [ ] Validación entrada en formularios (client + server)
- [ ] No expone datos sensibles en logs/consola

### Infra/Repo
- [ ] `.gitignore` auditado: secretos, build artifacts, `.env*`, `*.log`, `coverage/`
- [ ] GitHub Actions: `permissions: read-all` mínimo, secrets en `Settings > Secrets`
- [ ] Docker: non-root user, multi-stage, no secretos en imagen
- [ ] Base de datos: SSL obligatorio, usuario no-superuser, backups automatizados

## Remediación Automática
| Severidad | Acción |
|-----------|--------|
| **Crítica** | `backend-architect` fixea INMEDIATAMENTE (Helmet, CORS, secretos expuestos, mock en prod) |
| **Alta** | `backend-architect` fixea en mismo ciclo (throttler, Swagger, validation) |
| **Media** | Reporta, agenda para próximo ciclo roadmap (logging, deps outdated) |
| **Baja** | Reporta, documenta en Bitacora (warnings, best practices) |

## Flujo
```
security-reviewer: Escanea scope → genera hallazgos tabla
    ↓
Si Crítico/Alta:
    backend-architect: Remedia → re-ejecuta escaneo scope reducido
    ↓
    Si persiste tras 2 intentos → ALERTA (log + state.consecutiveFailures++)
    ↓
bitacora-keeper: Documenta hallazgos + remediaciones en Bitacora.md
    ↓
Actualiza ROADMAP.md items 2.11, 2.12, 2.13, 4.5 si resueltos
```

## Estado
- Lee/escribe: `.opencode/state/cycle-state.json` → `cycles.security-continuous`
- `scanScope`: `full` | `deps` | `secrets` | `config` | `auth`
- Log: `.opencode/state/cycle-seguridad-<ISO8601>.log`

## Ejecución Manual
```
/ciclo-autonomo seguridad ejecutar-una
```

## Integración CI/CD
Este ciclo **debe replicarse** en GitHub Actions (`.github/workflows/security.yml`):
- `npm audit` + `flutter analyze` en PR
- `security-reviewer` como job separado
- Bloquea merge si Crítico/Alta