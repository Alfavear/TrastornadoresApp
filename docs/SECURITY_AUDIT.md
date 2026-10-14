# Auditoría de seguridad — cierre 14/10/2026 (4.7)

Checklist: `.opencode/skills/security-checklist/SKILL.md`.

## Verificado OK
- Helmet global + Throttler 100/min + notify 10–20/min (2.11, tests `app.module.spec`).
- CORS por ambiente con allowlist prod (2.12, `cors.config.spec`).
- Swagger apagado en prod salvo `ENABLE_SWAGGER=true` (2.13).
- `ValidationPipe({whitelist, transform})` global; Firebase mock solo no-prod; RBAC en admin endpoints; secretos fuera del repo e historial (8.1).
- Bug crítico cerrado: guard no eleva `PARTICIPANT` (test regresión).

## Hallazgos conocidos NO cerrados (upstream, sin fix seguro)
- `npm audit`: 2 críticas transitivas (`handlebars` vía `@nestjs/swagger`, `proxy-addr` vía `@nestjs/platform-express`) + 11 altas + 11 moderadas. `npm audit fix` sin `--force` no las elimina; `--force` rompería Prisma/Firebase (breaking). Acción: vigilar releases NestJS/Swagger y re-auditar; no exponer upload multipart innecesario (superficie ya mínima).

## Riesgo residual aceptado
- Bajo: app sin uploads de archivos (multer/busboy no ejercitados), Handlebars solo en tooling Swagger.
