import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trastornadores_app/features/auth/presentation/providers/user_provider.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

  group('UserProfile', () {
    test('defaults role to PARTICIPANT', () {
      const p = UserProfile(id: '1', name: 'A', email: 'a@test.com');
      expect(p.role, 'PARTICIPANT');
      expect(p.phone, isNull);
      expect(p.photoUrl, isNull);
    });

    test('mockProfile es ADMIN', () {
      expect(mockProfile.role, 'ADMIN');
      expect(mockProfile.id, 'mock-uid-123');
    });

    test('currentUserProvider default es mockProfile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(currentUserProvider), mockProfile);
    });

    test('currentUserProvider se puede sobrescribir', () {
      final container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith(
          (ref) => const UserProfile(
              id: 'x', name: 'X', email: 'x@test.com', role: 'PARTICIPANT'),
        ),
      ]);
      addTearDown(container.dispose);
      expect(container.read(currentUserProvider).role, 'PARTICIPANT');
    });
  });

  group('fetchCurrentUser', () {
    test('retorna perfil del backend cuando /users/me ok', () async {
      when(() => mockDio.get('/users/me')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/users/me'),
          data: {
            'id': 'u1',
            'name': 'Ana',
            'email': 'ana@test.com',
            'phone': '3001',
            'photoUrl': 'http://photo',
            'role': 'ADMIN',
          },
          statusCode: 200,
        ),
      );

      final profile = await fetchCurrentUser(mockDio);

      expect(profile.id, 'u1');
      expect(profile.name, 'Ana');
      expect(profile.role, 'ADMIN');
      expect(profile.phone, '3001');
    });

    test('usa defaults cuando faltan campos', () async {
      when(() => mockDio.get('/users/me')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/users/me'),
          data: <String, dynamic>{},
          statusCode: 200,
        ),
      );

      final profile = await fetchCurrentUser(mockDio);

      expect(profile.id, 'mock-uid-123');
      expect(profile.name, 'Servidor Trastornador');
      expect(profile.role, 'PARTICIPANT');
    });

    test('retorna mockProfile en error de red (fallback offline)', () async {
      when(() => mockDio.get('/users/me')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/users/me')),
      );

      final profile = await fetchCurrentUser(mockDio);
      expect(profile, mockProfile);
    });

    test('retorna mockProfile si data no es Map', () async {
      when(() => mockDio.get('/users/me')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/users/me'),
          data: 'string-invalida',
          statusCode: 200,
        ),
      );

      final profile = await fetchCurrentUser(mockDio);
      expect(profile, mockProfile);
    });
  });

  group('resolveRedirect (3.13 sesion expirada)', () {
    const admin = UserProfile(
        id: 'a', name: 'A', email: 'a@test.com', role: 'ADMIN');
    const participant = UserProfile(
        id: 'p', name: 'P', email: 'p@test.com', role: 'PARTICIPANT');

    test('401 redirige a /login desde cualquier ruta', () {
      expect(
        resolveRedirect(
            user: participant, sessionExpired: true, location: '/schedule'),
        '/login',
      );
      expect(
        resolveRedirect(
            user: admin, sessionExpired: true, location: '/admin'),
        '/login',
      );
    });

    test('no redirige si ya esta en /login', () {
      expect(
        resolveRedirect(
            user: participant, sessionExpired: true, location: '/login'),
        isNull,
      );
    });

    test('no-admin a /admin va a /schedule', () {
      expect(
        resolveRedirect(
            user: participant,
            sessionExpired: false,
            location: '/admin'),
        '/schedule',
      );
    });

    test('admin a /admin no redirige', () {
      expect(
        resolveRedirect(
            user: admin, sessionExpired: false, location: '/admin'),
        isNull,
      );
    });

    test('ruta normal sin expiracion no redirige', () {
      expect(
        resolveRedirect(
            user: participant,
            sessionExpired: false,
            location: '/schedule'),
        isNull,
      );
    });

    test('sessionExpiredProvider inicia en false y se puede marcar', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(sessionExpiredProvider), false);
      container.read(sessionExpiredProvider.notifier).state = true;
      expect(container.read(sessionExpiredProvider), true);
    });
  });
}
