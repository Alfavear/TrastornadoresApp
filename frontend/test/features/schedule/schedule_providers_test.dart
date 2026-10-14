import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trastornadores_app/features/schedule/data/schedule_repository.dart';
import 'package:trastornadores_app/features/schedule/domain/models/schedule_model.dart';
import 'package:trastornadores_app/features/schedule/presentation/providers/schedule_providers.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  group('scheduleRepositoryProvider', () {
    test('provee ScheduleRepository desde dioProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(scheduleRepositoryProvider),
          isA<ScheduleRepository>());
    });
  });

  group('schedulesProvider', () {
    test('emite lista cuando el repositorio ok', () async {
      final repo = MockScheduleRepository();
      const list = [
        ScheduleModel(id: 's1', month: 10, year: 2026, isOpen: true)
      ];
      when(() => repo.getSchedules()).thenAnswer((_) async => list);

      final container = ProviderContainer(overrides: [
        scheduleRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      expect(await container.read(schedulesProvider.future), list);
      verify(() => repo.getSchedules()).called(1);
    });

    test('emite error cuando el repositorio falla', () async {
      final repo = MockScheduleRepository();
      when(() => repo.getSchedules())
          .thenThrow(Exception('Failed to fetch schedules'));

      final container = ProviderContainer(overrides: [
        scheduleRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      await expectLater(
        container.read(schedulesProvider.future),
        throwsException,
      );
    });

    test('emite lista vacia sin romperse (offline tolerante)', () async {
      final repo = MockScheduleRepository();
      when(() => repo.getSchedules()).thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        scheduleRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      expect(await container.read(schedulesProvider.future), isEmpty);
    });
  });

  group('dioProvider', () {
    test('tiene baseUrl y content-type json', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final dio = container.read(dioProvider);
      expect(dio.options.baseUrl, 'http://localhost:3000');
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.interceptors, isNotEmpty);
    });
  });
}
