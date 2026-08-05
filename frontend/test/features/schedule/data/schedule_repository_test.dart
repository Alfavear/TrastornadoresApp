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

  group('ScheduleRepository', () {
    test('getSchedules returns list of ScheduleModel on success', () async {
      final mockResponse = {
        'data': [
          {
            'id': 'sched1',
            'month': 8,
            'year': 2026,
            'isOpen': true,
            'dates': []
          }
        ]
      };

      when(() => mockDio.get('/schedule')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/schedule'),
          data: mockResponse['data'],
          statusCode: 200,
        ),
      );

      final result = await repository.getSchedules();

      expect(result, isA<List<ScheduleModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'sched1');
      verify(() => mockDio.get('/schedule')).called(1);
    });

    test('getSchedules throws Exception on failure', () async {
      when(() => mockDio.get('/schedule')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/schedule')),
      );

      expect(() => repository.getSchedules(), throwsException);
    });

    test('registerAvailability posts successfully', () async {
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
}
