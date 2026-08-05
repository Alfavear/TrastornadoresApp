# Reglas y Contexto para Agentes de IA (TrastornadoresApp)

Este archivo contiene el contexto general, las reglas de arquitectura y la visión del proyecto para que cualquier agente de IA pueda entender rápidamente de qué trata el repositorio y continuar el desarrollo de forma coherente.

## 📌 Directiva Crítica
**Antes de proponer cambios arquitectónicos o implementar nuevas funcionalidades, el agente DEBE leer obligatoriamente el archivo `Bitacora.md` en la raíz del proyecto.** La bitácora contiene el registro histórico exacto de lo que ya está implementado.

## 🔧 Contexto de opencode
Para conocer la configuración de opencode de este proyecto (MCP servers, reglas de sesión, estructura), leer el archivo `OPENCODE.md` en la raíz del proyecto.

## 📖 Visión del Proyecto
TrastornadoresApp es una plataforma moderna diseñada para apoyar la organización, coordinación y administración de los diferentes ministerios y actividades del movimiento Trastornadores. 
- **Enfoque:** Modular y escalable.
- **Estrategia:** Mobile First (Web y Android) con una única base de código.

## 🏗️ Stack Tecnológico y Arquitectura
- **Backend:** Node.js, NestJS, TypeScript estricto.
- **Base de Datos:** PostgreSQL con Prisma ORM (Desarrollo local con Docker).
- **Autenticación:** Firebase Authentication (Google Sign-In). Las rutas del backend están protegidas con un `FirebaseAuthGuard` que verifica los tokens contra el Admin SDK de Firebase.
- **Frontend:** Flutter.
  - **Estado y DI:** Riverpod.
  - **Navegación:** GoRouter.
  - **Conexión API:** Dio.
  - **Modelos:** Freezed y JSON Serializable.
- **Patrón de Diseño (Ambos):** Clean Architecture (Core, Domain, Data, Presentation).

## 🚀 Módulos (Ruta de Desarrollo)
### 1. Cronograma de Disponibilidad (En desarrollo actual)
- Lógica de auto-generación de fechas: Únicamente Jueves, Sábados y Domingos.
- **Rol Participante:** UI para confirmar asistencia ("Puedo" / "No Puedo").
- **Rol Administrador:** Vistas de Calendario, Agenda, Matriz (tipo Excel) y Dashboard estadístico.

### 2. Módulos Futuros (No implementar hasta finalizar Cronograma)
- Programación de servidores.
- Gestión de finanzas.
- Reporte de asistencia a servicios.
- Base de datos de integrantes y ministerios.
- Gestión de inventario.

## ⚠️ Reglas de Código (Code Guidelines)
1. **No romper la Clean Architecture:** Mantener separada la lógica de negocio, los repositorios y la UI.
2. **Flutter:** Favorecer componentes sin estado (StatelessWidget) envueltos en `ConsumerWidget` de Riverpod.
3. **Backend:** Todo endpoint debe estar fuertemente tipado con DTOs (`class-validator`) y documentado con Swagger (`@nestjs/swagger`).
4. **Respuestas en Español:** El código (variables, funciones) va en inglés, pero los textos de la UI y los comentarios/documentación deben ser en español.
