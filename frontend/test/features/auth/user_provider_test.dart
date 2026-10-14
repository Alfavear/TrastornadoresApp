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
}
