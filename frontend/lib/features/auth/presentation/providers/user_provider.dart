import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String role; // 'ADMIN' or 'PARTICIPANT'

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.role = 'PARTICIPANT',
  });
}

const mockProfile = UserProfile(
  id: 'mock-uid-123',
  name: 'Servidor Trastornador',
  email: 'servidor@trastornadores.org',
  phone: '573000000000',
  role: 'ADMIN',
);

final currentUserProvider = StateProvider<UserProfile>((ref) => mockProfile);

Future<UserProfile> fetchCurrentUser(Dio dio) async {
  try {
    final response = await dio.get('/users/me');
    final data = response.data as Map<String, dynamic>;
    return UserProfile(
      id: (data['id'] ?? 'mock-uid-123').toString(),
      name: data['name']?.toString() ?? 'Servidor Trastornador',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
      role: data['role']?.toString() ?? 'PARTICIPANT',
    );
  } catch (e) {
    return mockProfile;
  }
}