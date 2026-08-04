import 'package:dio/dio.dart';
import '../domain/models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final response = await _dio.get('/schedule');
      return (response.data as List)
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
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
}
