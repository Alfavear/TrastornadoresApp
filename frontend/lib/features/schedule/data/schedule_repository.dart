import 'package:dio/dio.dart';
import '../domain/models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final response = await _dio.get('/schedule');
      final data = response.data;
      if (data is List) {
        return data.map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          return (data['data'] as List).map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [ScheduleModel.fromJson(data)];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  Future<void> registerAvailability({
    required String scheduleDateId,
    required String status,
  }) async {
    try {
      await _dio.post('/schedule/availability', data: {
        'scheduleDateId': scheduleDateId,
        'status': status, // 'PUEDO' or 'NO_PUEDO'
      });
    } catch (e) {
      throw Exception('Failed to register availability: $e');
    }
  }

  Future<ScheduleModel> createSchedule({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.post('/schedule', data: {
        'month': month,
        'year': year,
      });
      return ScheduleModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  Future<void> updateScheduleStatus({
    required String id,
    required bool isOpen,
  }) async {
    try {
      await _dio.patch('/schedule/$id/status', data: {'isOpen': isOpen});
    } catch (e) {
      throw Exception('Failed to update schedule status: $e');
    }
  }
}
