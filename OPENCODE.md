# Configuración de opencode - TrastornadoresApp

Este archivo documenta la configuración de opencode utilizada en este proyecto, para que futuras sesiones de IA tengan el contexto completo.

## 📌 Reglas para futuras sesiones

1. **Leer siempre `Bitacora.md`** (raíz) antes de proponer cambios arquitectónicos o nuevas funcionalidades. Contiene el registro histórico exacto de lo implementado.
2. **Leer siempre `.agents/AGENTS.md`** (raíz). Contiene la visión del proyecto, stack tecnológico y reglas de código (Clean Architecture, DTOs tipados, textos UI en español, código en inglés).
3. La configuración de opencode vive en **`opencode.json`** (raíz del proyecto). No existe config global en `~/.config/opencode/`.
4. **Los cambios en `opencode.json` NO se recargan en caliente**: después de editar cualquier archivo de config, indicar al usuario que reinicie opencode.

## 🔌 MCP Servers conectados

### Neon (Base de datos PostgreSQL en la nube)
- **Tipo:** `remote` (MCP hosteado por Neon).
- **URL:** `https://mcp.neon.tech/mcp`
- **Autenticación:** OAuth (sin API key). Al primer uso de las herramientas de Neon, se abre el navegador para autorizar el acceso a la cuenta de Neon.
- **Nota:** la autenticación por OAuth conecta a la cuenta personal de Neon. Si el agente necesita acceder a proyectos de una organización, hay que cambiar a API key (header `Authorization: Bearer <key>`).

### Stitch (Google Stitch UI Design & MCP)
- **Tipo:** `remote` (MCP de Google Stitch).
- **URL:** `https://stitch.googleapis.com/mcp`
- **Autenticación:** Header `X-Goog-Api-Key`.

Configuración actual:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [".agents/AGENTS.md", "Bitacora.md", "ROADMAP.md"],
  "skills": {
    "paths": [".opencode/skills"]
  },
  "mcp": {
    "neon": {
      "type": "remote",
      "url": "https://mcp.neon.tech/mcp",
      "enabled": true
    },
    "stitch": {
      "type": "remote",
      "url": "https://stitch.googleapis.com/mcp",
      "headers": {
        "X-Goog-Api-Key": "{env:STITCH_API_KEY}"
      },
      "enabled": true
    },
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer {env:GITHUB_TOKEN}"
      },
      "enabled": true
    },
    "postgres": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:password@localhost:5432/trastornadores"
      ],
      "enabled": true
    },
    "filesystem": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:/tmp/Trastornadores"
      ],
      "enabled": true
    },
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@latest"],
      "enabled": true
    }
  }
}
```

### GitHub (repositorio, issues y PRs)
- **Tipo:** `remote` — `https://api.githubcopilot.com/mcp/`
- **Autenticación:** header `Authorization: Bearer {env:GITHUB_TOKEN}` (PAT de GitHub).

### PostgreSQL (base local de desarrollo)
- **Tipo:** `local` — `@modelcontextprotocol/server-postgres`.
- Apunta a la base definida en `docker-compose.yml`. Requiere Docker levantado (`docker compose up -d db`).

### Filesystem
- **Tipo:** `local` — `@modelcontextprotocol/server-filesystem`, limitado a `C:/tmp/Trastornadores`.

### Playwright
- **Tipo:** `local` — `@playwright/mcp`.
- Pruebas E2E y navegación de la app Flutter Web.

## 🧠 Skills de proyecto

### `trastornadores-dev`
- **Ubicación:** `.opencode/skills/trastornadores-dev/SKILL.md`
- **Cuándo:** al implementar, modificar o revisar código del proyecto.
- **Qué hace:** carga la documentación obligatoria (Bitacora, AGENTS, OPENCODE), reglas de Clean Architecture e idioma, orden de desarrollo de módulos, comandos de verificación y estado actual.
- Se activa automáticamente cuando la tarea coincide con su descripción.

### Skills operativas complementarias

| Skill | Cuándo |
| --- | --- |
| `add-nestjs-module` | Al crear un módulo/endpoint NestJS (DTOs, Swagger, guard, Prisma). |
| `add-flutter-feature` | Al crear una feature Flutter bajo Clean Architecture. |
| `security-checklist` | En revisiones de seguridad y antes de desplegar. |
| `update-bitacora` | Al documentar avances o decisiones técnicas. |

## 🤖 Agentes de proyecto

Definidos en `.opencode/agent/`:

| Agente | Modelo | Rol |
| --- | --- | --- |
| `backend-architect` | `anthropic/claude-sonnet-4-5` | Arquitectura NestJS/Prisma, seguridad y escalabilidad. |
| `flutter-dev` | `anthropic/claude-sonnet-4-5` | Frontend Flutter/Riverpod bajo Clean Architecture. |
| `security-reviewer` | `anthropic/claude-opus-4-5` | Auditoría de seguridad (sin permisos de edición). |
| `code-reviewer` | `anthropic/claude-sonnet-4-5` | Revisión contra convenciones (sin permisos de edición). |
| `bitacora-keeper` | `anthropic/claude-haiku-4-5` | Sincroniza `Bitacora.md`, `ROADMAP.md` y `AGENTS.md`. |

> Si tu proveedor no es Anthropic, cambia el campo `model:` de cada archivo `.md`.

## 🛠️ Comandos de proyecto

Definidos en `.opencode/commands/`:

| Comando | Descripción |
| --- | --- |
| `/check` | Verifica todo el proyecto: build + lint + tests del backend y `flutter analyze` del frontend. |
| `/gen-models` | Regenera los modelos Freezed/JSON del frontend (`build_runner`). |
| `/bitacora` | Lee y resume `Bitacora.md` como contexto actual del proyecto. |
| `/estado` | Resumen del estado y **detecta documentación desactualizada** respecto al worktree. |
| `/actualizar-bitacora` | Sincroniza `Bitacora.md`, `ROADMAP.md` y `AGENTS.md` con el código real. |
| `/nuevo-modulo` | Crea un módulo NestJS nuevo siguiendo las convenciones. |
| `/revisar-seguridad` | Auditoría de seguridad contra la checklist del proyecto. |

### Flujo de trabajo recomendado

1. Inicio de sesión → `/estado` (contexto + detecta desfases de documentación).
2. Durante → elige agente según la tarea o deja que `build` opere.
3. Cierre → `/actualizar-bitacora` para dejar Bitácora, Roadmap y AGENTS al día.

## 📂 Estructura relevante del proyecto

- `backend/` - NestJS + TypeScript estricto + Prisma + PostgreSQL (local con Docker).
- `frontend/` - Flutter + Riverpod + GoRouter + Dio + Freezed.
- `.agents/AGENTS.md` - Reglas y contexto para agentes de IA.
- `opencode.json` - Configuración de opencode (MCP, skills, contexto inyectado).
- `.opencode/agent/` - Agentes de proyecto.
- `.opencode/skills/` - Skills de proyecto.
- `.opencode/commands/` - Comandos personalizados.
- `Bitacora.md` - Bitácora de desarrollo (obligatoria de leer).
- `ROADMAP.md` - Hoja de ruta con el estado de avance por ítems.
- `docker-compose.yml` - PostgreSQL local de desarrollo.

## ⚠️ Notas

- El MCP de Neon gestiona proyectos/bases en la nube de Neon; **no reemplaza** el PostgreSQL local de Docker definido en `docker-compose.yml`.
- Mantener los secretos (firebase-service-account.json, google-services.json, API keys) fuera del control de versiones según `.gitignore`.
- Variables de entorno requeridas por los MCPs: `GITHUB_TOKEN` (MCP GitHub), `STITCH_API_KEY` (MCP Stitch) y `DATABASE_URL` (MCP `postgres`). Sin ellas esos servidores fallarán al iniciar o al ejecutar una tool. Alternativa a las API keys: OAuth guardada con `opencode mcp auth <server>` en `~/.local/share/opencode/mcp-auth.json` (hoy con `neon` y `stitch`).
- El MCP `postgres` usa `{env:DATABASE_URL}` (14/10/2026): apunta a la base local de `docker-compose.yml` si esa variable define la URL local; en máquinas **sin Docker/WSL** se puede exportar en el scope `User` la URL de Neon (misma que `backend/.env`) y conecta a la nube.
- La configuración de opencode **no se recarga en caliente**: reinicia opencode tras editar `opencode.json` o los archivos de `.opencode/`.
