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
        "X-Goog-Api-Key": "YOUR_STITCH_API_KEY"
      },
      "enabled": true
    }
  }
}
```

## 🧠 Skills de proyecto

### `trastornadores-dev`
- **Ubicación:** `.opencode/skills/trastornadores-dev/SKILL.md`
- **Cuándo:** al implementar, modificar o revisar código del proyecto.
- **Qué hace:** carga la documentación obligatoria (Bitacora, AGENTS, OPENCODE), reglas de Clean Architecture e idioma, orden de desarrollo de módulos, comandos de verificación y estado actual.
- Se activa automáticamente cuando la tarea coincide con su descripción.

## 🛠️ Comandos de proyecto

Definidos en `.opencode/commands/`:

| Comando | Descripción |
| --- | --- |
| `/check` | Verifica todo el proyecto: build + lint + tests del backend y `flutter analyze` del frontend. |
| `/gen-models` | Regenera los modelos Freezed/JSON del frontend (`build_runner`). |
| `/bitacora` | Lee y resume `Bitacora.md` como contexto actual del proyecto. |

## 📂 Estructura relevante del proyecto

- `backend/` - NestJS + TypeScript estricto + Prisma + PostgreSQL (local con Docker).
- `frontend/` - Flutter + Riverpod + GoRouter + Dio + Freezed.
- `.agents/AGENTS.md` - Reglas y contexto para agentes de IA.
- `opencode.json` - Configuración de opencode (MCP, skills).
- `.opencode/skills/` - Skills de proyecto.
- `.opencode/commands/` - Comandos personalizados.
- `Bitacora.md` - Bitácora de desarrollo (obligatoria de leer).
- `docker-compose.yml` - PostgreSQL local de desarrollo.

## ⚠️ Notas

- El MCP de Neon gestiona proyectos/bases en la nube de Neon; **no reemplaza** el PostgreSQL local de Docker definido en `docker-compose.yml`.
- Mantener los secretos (firebase-service-account.json, google-services.json, API keys) fuera del control de versiones según `.gitignore`.
