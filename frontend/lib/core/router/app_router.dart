import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/schedule/presentation/admin_home_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';

import '../../features/auth/presentation/providers/user_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final expired = ref.read(sessionExpiredProvider);
      return resolveRedirect(
        user: user,
        sessionExpired: expired,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});
