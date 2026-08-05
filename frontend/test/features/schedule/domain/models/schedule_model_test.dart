import 'package:flutter_test/flutter_test.dart';
import 'package:trastornadores_app/features/schedule/domain/models/schedule_model.dart';

void main() {
  group('Schedule Models JSON Serialization Tests', () {
    test('UserModel.fromJson should correctly parse JSON', () {
      final json = {
        'id': 'user123',
        'name': 'Juan Perez',
        'email': 'juan@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user123');
      expect(user.name, 'Juan Perez');
      expect(user.email, 'juan@example.com');
    });

    test('AvailabilityModel.fromJson should correctly parse JSON with User', () {
      final json = {
        'id': 'avail123',
        'userId': 'user123',
        'scheduleDateId': 'date123',
        'status': 'PUEDO',
        'user': {
          'id': 'user123',
          'name': 'Juan Perez',
          'email': 'juan@example.com',
        }
      };

      final availability = AvailabilityModel.fromJson(json);

      expect(availability.id, 'avail123');
      expect(availability.status, 'PUEDO');
      expect(availability.user, isNotNull);
      expect(availability.user?.name, 'Juan Perez');
    });

    test('ScheduleDateModel.fromJson should correctly parse JSON', () {
      final json = {
        'id': 'date123',
        'date': '2026-08-06T10:00:00.000Z',
        'scheduleId': 'sched123',
        'availabilities': []
      };

      final scheduleDate = ScheduleDateModel.fromJson(json);

      expect(scheduleDate.id, 'date123');
      expect(scheduleDate.date, DateTime.parse('2026-08-06T10:00:00.000Z'));
      expect(scheduleDate.availabilities, isEmpty);
    });

    test('ScheduleModel.fromJson should correctly parse JSON', () {
      final json = {
        'id': 'sched123',
        'month': 8,
        'year': 2026,
        'isOpen': true,
        'dates': [
          {
            'id': 'date123',
            'date': '2026-08-06T10:00:00.000Z',
            'scheduleId': 'sched123',
            'availabilities': []
          }
        ]
      };

      final schedule = ScheduleModel.fromJson(json);

      expect(schedule.id, 'sched123');
      expect(schedule.month, 8);
      expect(schedule.year, 2026);
      expect(schedule.isOpen, true);
      expect(schedule.dates.length, 1);
      expect(schedule.dates.first.id, 'date123');
    });
  });
}
