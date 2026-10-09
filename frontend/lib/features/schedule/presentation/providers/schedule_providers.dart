import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/schedule_repository.dart';
import '../../domain/models/schedule_model.dart';

/// Token de respaldo para desarrollo.
///
/// El backend solo verifica el token cuando Firebase Admin estÃ¡ inicializado;
/// en modo desarrollo (`FirebaseService.isMockEnabled`) cae al usuario mock ante
/// cualquier token. En producciÃ³n este valor nunca debe usarse.
const String _devFallbackToken = 'dev-token';

final dioProvider = Provider<Dio>((ref) {
  // Configured to point to the NestJS backend.
  // En el emulador de Android usar http://10.0.2.2:3000
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      String? token;

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // ID token real de Firebase Authentication (renovado en cada peticiÃ³n).
          token = await user.getIdToken();
        }
      } catch (_) {
        // Firebase no inicializado en este dispositivo: se usa el respaldo.
      }

      options.headers['Authorization'] = 'Bearer ${token ?? _devFallbackToken}';
      handler.next(options);
    },
  ));

  return dio;
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleRepository(dio);
});

final schedulesProvider = FutureProvider<List<ScheduleModel>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getSchedules();
});
