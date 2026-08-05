---
description: Regenera los modelos Freezed/JSON del frontend (build_runner)
agent: build
---

Ejecuta `dart run build_runner build --delete-conflicting-outputs` en el directorio `frontend` para regenerar los archivos `.freezed.dart` y `.g.dart` de los modelos.

Si hay conflictos de resolución, revisa el `pubspec.yaml` y ajusta versiones según la bitácora (ej. `json_serializable: ^6.9.5`).