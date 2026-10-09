---
name: add-nestjs-module
description: Guía paso a paso para crear un nuevo módulo NestJS en TrastornadoresApp (controller, service, DTOs, Swagger, guard, Prisma). Úsala cuando agregues un módulo o endpoint al backend.
---

# Crear un módulo NestJS

Toma como referencia `backend/src/modules/schedule`.

## Pasos
1. Crea la carpeta `backend/src/modules/<nombre>/`.
2. **DTO** en `dto/<nombre>.dto.ts`: usa `@ApiProperty` de `@nestjs/swagger` y validadores de `class-validator` (`@IsInt`, `@IsIn`, `@IsUUID`, etc.).
3. **Service** `<nombre>.service.ts`: `@Injectable()`, inyecta `PrismaService`. Toda la lógica de negocio aquí.
4. **Controller** `<nombre>.controller.ts`:
   - `@ApiTags(...)`, `@ApiBearerAuth()`, `@UseGuards(FirebaseAuthGuard)`, `@ApiOperation` en cada ruta.
   - El usuario autenticado sale de `req.user`; típa el `Request` de Express (ver `schedule.controller.ts`).
5. **Module** `<nombre>.module.ts`: declara `controllers` y `providers`.
6. Registra el módulo en `backend/src/app.module.ts`.
7. Si hay entidades nuevas, edita `prisma/schema.prisma` y ejecuta `npx prisma migrate dev --name <nombre>` + `npx prisma generate`.

## Verificación obligatoria
```bash
npm run lint
npm run build
npm test
```
No des por terminado hasta que los tres pasen. Actualiza `Bitacora.md`.

## Referencia de un endpoint protegido
```ts
@ApiTags('Nombre')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('nombre')
export class NombreController {
  constructor(private readonly service: NombreService) {}

  @Get()
  @ApiOperation({ summary: 'Descripción en español' })
  listar() {
    return this.service.listar();
  }
}
```
