---
name: add-flutter-feature
description: Guía para crear una nueva feature en el frontend Flutter de TrastornadoresApp bajo Clean Architecture (domain, data, presentation, providers Riverpod). Úsala al agregar pantallas, modelos o repositorios.
---

# Crear una feature Flutter

Referencia: `frontend/lib/features/schedule`.

## Estructura
```
lib/features/<feature>/
  domain/
    models/<modelo>.dart          # Freezed + JSON (part 'x.freezed.dart' y part 'x.g.dart')
    <feature>_repository.dart     # contrato abstracto
  data/
    <feature>_repository_impl.dart # implementación con Dio
  presentation/
    <feature>_screen.dart
    providers/<feature>_providers.dart
    views/                        # sub-vistas si aplica
```

## Pasos
1. **Modelo**: crea la clase `@freezed` con factory y `fromJson`; declara las partes generadas.
2. **Repositorio**: interface en `domain/`, implementación en `data/` usando `Dio` (obtenlo del `dioProvider`).
3. **Providers**: expón el repositorio y los `FutureProvider`/`AsyncNotifierProvider` necesarios.
4. **UI**: `ConsumerWidget` / `ConsumerStatefulWidget`. Textos en español.
5. Regenera el código de Freezed:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   ```

## Reglas
- No accedas a `Dio` directamente en la UI; siempre vía repositorio/provider.
- Las peticiones ya llevan el Bearer token por el interceptor de `dioProvider`.
- Reutiliza `core/widgets` (logos) y respeta la paleta Royal Blue/gold existente.
- Actualiza `Bitacora.md` al terminar.
