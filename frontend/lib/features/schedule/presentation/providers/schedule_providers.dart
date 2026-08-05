import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/schedule_repository.dart';
import '../../domain/models/schedule_model.dart';

final dioProvider = Provider<Dio>((ref) {
  // Configured to point to the NestJS backend
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:3000', // Adjust for production or mobile emulator (e.g. 10.0.2.2)
    headers: {
      'Content-Type': 'application/json',
      // Token de desarrollo (mock). En producción llega desde Firebase Authentication.
      'Authorization': 'Bearer dev-token',
    },
  ));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleRepository(dio);
});

final schedulesProvider = FutureProvider<List<ScheduleModel>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getSchedules();
});
