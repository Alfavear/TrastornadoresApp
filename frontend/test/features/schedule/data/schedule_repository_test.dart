import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trastornadores_app/features/schedule/data/schedule_repository.dart';
import 'package:trastornadores_app/features/schedule/domain/models/schedule_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ScheduleRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = ScheduleRepository(mockDio);
  });

  group('ScheduleRepository getSchedules', () {
    test('returns list on List response', () async {
      when(() => mockDio.get('/schedule')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule'),
          data: [
            {
              'id': 'sched1',
              'month': 8,
              'year': 2026,
              'isOpen': true,
              'dates': []
            }
          ],
          statusCode: 200,
        ),
      );

      final result = await repository.getSchedules();

      expect(result, isA<List<ScheduleModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'sched1');
      verify(() => mockDio.get('/schedule')).called(1);
    });

    test('returns list on Map-wrapped data response', () async {
      when(() => mockDio.get('/schedule')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule'),
          data: {
            'data': [
              {
                'id': 'sched2',
                'month': 9,
                'year': 2026,
                'isOpen': false,
                'dates': []
              }
            ]
          },
          statusCode: 200,
        ),
      );

      final result = await repository.getSchedules();
      expect(result.length, 1);
      expect(result.first.id, 'sched2');
      expect(result.first.isOpen, false);
    });

    test('returns single-item list on bare Map response', () async {
      when(() => mockDio.get('/schedule')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule'),
          data: {
            'id': 'sched3',
            'month': 10,
            'year': 2026,
            'isOpen': true,
            'dates': []
          },
          statusCode: 200,
        ),
      );

      final result = await repository.getSchedules();
      expect(result.length, 1);
      expect(result.first.id, 'sched3');
    });

    test('returns empty list on unexpected payload', () async {
      when(() => mockDio.get('/schedule')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule'),
          data: 'not-a-list-nor-map',
          statusCode: 200,
        ),
      );

      expect(await repository.getSchedules(), isEmpty);
    });

    test('throws Exception on failure with context', () async {
      when(() => mockDio.get('/schedule')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/schedule')),
      );

      expect(() => repository.getSchedules(), throwsException);
    });
  });

  group('ScheduleRepository availability', () {
    test('registerAvailability PUEDO posts successfully', () async {
      when(() => mockDio.post('/schedule/availability', data: any(named: 'data')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule/availability'),
          statusCode: 201,
        ),
      );

      await repository.registerAvailability(
        scheduleDateId: 'date1',
        status: 'PUEDO',
      );

      verify(() => mockDio.post('/schedule/availability', data: {
            'scheduleDateId': 'date1',
            'status': 'PUEDO',
          })).called(1);
    });

    test('registerAvailability NO_PUEDO posts successfully', () async {
      when(() => mockDio.post('/schedule/availability', data: any(named: 'data')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule/availability'),
          statusCode: 201,
        ),
      );

      await repository.registerAvailability(
        scheduleDateId: 'date2',
        status: 'NO_PUEDO',
      );

      verify(() => mockDio.post('/schedule/availability', data: {
            'scheduleDateId': 'date2',
            'status': 'NO_PUEDO',
          })).called(1);
    });

    test('registerAvailability throws Exception on failure', () async {
      when(() => mockDio.post('/schedule/availability', data: any(named: 'data')))
          .thenThrow(
        DioException(requestOptions: RequestOptions(path: '/schedule/availability')),
      );

      expect(
        () => repository.registerAvailability(
          scheduleDateId: 'date1',
          status: 'PUEDO',
        ),
        throwsException,
      );
    });
  });

  group('ScheduleRepository admin actions', () {
    test('createSchedule posts and parses response', () async {
      when(() => mockDio.post('/schedule', data: any(named: 'data')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule'),
          data: {
            'id': 'new1',
            'month': 11,
            'year': 2026,
            'isOpen': true,
            'dates': []
          },
          statusCode: 201,
        ),
      );

      final result =
          await repository.createSchedule(month: 11, year: 2026);

      expect(result.id, 'new1');
      verify(() => mockDio.post('/schedule', data: {
            'month': 11,
            'year': 2026,
          })).called(1);
    });

    test('createSchedule throws on duplicate/error', () async {
      when(() => mockDio.post('/schedule', data: any(named: 'data')))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/schedule'),
          response: Response(
            requestOptions: RequestOptions(path: '/schedule'),
            statusCode: 400,
          ),
        ),
      );

      expect(
        () => repository.createSchedule(month: 8, year: 2026),
        throwsException,
      );
    });

    test('updateScheduleStatus patches correctly (close)', () async {
      when(() => mockDio.patch('/schedule/s1/status', data: any(named: 'data')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule/s1/status'),
          statusCode: 200,
        ),
      );

      await repository.updateScheduleStatus(id: 's1', isOpen: false);

      verify(() => mockDio.patch('/schedule/s1/status', data: {
            'isOpen': false,
          })).called(1);
    });

    test('updateScheduleStatus patches correctly (reopen)', () async {
      when(() => mockDio.patch('/schedule/s1/status', data: any(named: 'data')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule/s1/status'),
          statusCode: 200,
        ),
      );

      await repository.updateScheduleStatus(id: 's1', isOpen: true);

      verify(() => mockDio.patch('/schedule/s1/status', data: {
            'isOpen': true,
          })).called(1);
    });

    test('updateScheduleStatus throws on failure', () async {
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/x')),
      );

      expect(
        () => repository.updateScheduleStatus(id: 's1', isOpen: true),
        throwsException,
      );
    });
  });

  group('ScheduleRepository notifications', () {
    test('notifyGroup posts to correct endpoint', () async {
      when(() => mockDio.post('/schedule/notify/group/d1')).thenAnswer(
        (_) async => Response(
          requestOptions:
              RequestOptions(path: '/schedule/notify/group/d1'),
          statusCode: 200,
        ),
      );

      await repository.notifyGroup('d1');
      verify(() => mockDio.post('/schedule/notify/group/d1')).called(1);
    });

    test('notifyGroup throws on failure', () async {
      when(() => mockDio.post(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/x')),
      );
      expect(() => repository.notifyGroup('d1'), throwsException);
    });

    test('notifyReminder posts to correct endpoint with order date/user', () async {
      when(() => mockDio.post('/schedule/notify/reminder/d1/u1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
              path: '/schedule/notify/reminder/d1/u1'),
          statusCode: 200,
        ),
      );

      await repository.notifyReminder('d1', 'u1');
      verify(() => mockDio.post('/schedule/notify/reminder/d1/u1'))
          .called(1);
    });

    test('notifyReminder throws on failure', () async {
      when(() => mockDio.post(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/x')),
      );
      expect(() => repository.notifyReminder('d1', 'u1'), throwsException);
    });
  });

  group('ScheduleRepository offline/retry', () {
    test('propaga error de red como Exception con mensaje', () async {
      when(() => mockDio.get('/schedule')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/schedule'),
          error: 'SocketException: Failed host lookup',
        ),
      );

      try {
        await repository.getSchedules();
        fail('debio lanzar');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Failed to fetch schedules'));
      }
    });
  });
}
