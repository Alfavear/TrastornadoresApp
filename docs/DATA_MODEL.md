# Modelo de datos y flujo de roles — TrastornadoresApp

## Diagrama (Prisma → PostgreSQL)

```
User 1───* Availability *───1 ScheduleDate *───1 Schedule
```

## Tablas

### User
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | interno (`User.id`, NUNCA exponer `firebaseUid` como FK) |
| firebaseUid | string unique | sub del ID token Firebase |
| email | string unique | login + allowlist `ADMIN_EMAILS` |
| name | string | |
| phone | string? | WhatsApp obligatorio a nivel producto |
| photoUrl | string? | |
| role | `ADMIN` \| `PARTICIPANT` | default `PARTICIPANT` |
| lastAccess | DateTime | se actualiza en cada `syncUser` |

### Schedule (cronograma mensual)
| Campo | Notas |
|---|---|
| month 1–12, year | únicos por par (`findFirst({month, year})` rechaza duplicado) |
| isOpen | `true` = servidores pueden votar; `false` = solo lectura (admin puede) |
| dates | generadas Jue(4)/Sáb(6)/Dom(0). Ej. oct-2026 → 14 fechas |

### ScheduleDate
Fecha concreta + `scheduleId` (cascade). Incluye `availabilities(status=PUEDO)` para notificar.

### Availability
`@@unique([userId, scheduleDateId])` → `upsert` idempotente. `status: PUEDO | NO_PUEDO`.

## Flujo de roles

```
Firebase ID token
  → FirebaseAuthGuard.verifyIdToken
  → UsersService.findByFirebaseUid
  → request.user.role =
      dbUser.role                       // si existe en DB (respeta PARTICIPANT)
      ?? (isBootstrapAdmin(uid,email)
            ? ADMIN : PARTICIPANT)      // solo si NO existe en DB
  → RolesGuard(@Roles(ADMIN)) en POST /schedule, PATCH :id/status, notify/*
  → UsersService.syncUser NUNCA degrada: update.role = bootstrap ? ADMIN : undefined
```

Bootstrap: `ADMIN_UIDS` (uid exacto) + `ADMIN_EMAILS` (case-insensitive). El mock de dev (`mock-uid-123`) solo es ADMIN si está en allowlist.

## Reglas críticas (no romper)
1. `registerAvailability` usa `User.id` interno vía `getOrCreateByFirebaseUid`, jamás `firebaseUid` como FK.
2. Cronograma cerrado: solo `ADMIN` puede votar (`scheduleDate.schedule.isOpen` check).
3. `Availability` siempre por `upsert` en la clave compuesta (llamadas concurrentes seguras).
4. Notificaciones solo a `status=PUEDO` con `phone` no nulo; `sentCount` cuenta envíos reales.
