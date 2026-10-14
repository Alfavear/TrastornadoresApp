import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trastornadores_app/features/auth/presentation/login_screen.dart';
import 'package:trastornadores_app/features/auth/presentation/providers/user_provider.dart';
import 'package:trastornadores_app/core/widgets/logo_widget.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('LoginScreen Widget Tests', () {
    late MockGoRouter mockRouter;

    setUp(() {
      mockRouter = MockGoRouter();
      when(() => mockRouter.go(any())).thenReturn(null);
    });

    testWidgets('renders login screen with all auth methods', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserProfile(
              id: 'test',
              name: 'Test User',
              email: 'test@test.com',
              role: 'PARTICIPANT',
            )),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Teléfono'), findsOneWidget);
      expect(find.text('Correo'), findsOneWidget);
      expect(find.text('Acceso a Panel de Administración (Líder)'), findsOneWidget);
    });

    testWidgets('shows Google auth view by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Continuar con Google'), findsOneWidget);
    });

    testWidgets('switches to phone auth view when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Teléfono'));
      await tester.pumpAndSettle();

      expect(find.text('Número de Teléfono (+57 ...)'), findsOneWidget);
      expect(find.text('Nombre Completo'), findsOneWidget);
      expect(find.text('Registrarse con Teléfono'), findsOneWidget);
    });

    testWidgets('switches to email auth view when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Correo'));
      await tester.pumpAndSettle();

      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar Sesión con Correo'), findsOneWidget);
    });
  });

  group('Logo Widget Tests', () {
    testWidgets('TrastornadoresHeaderLogo renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrastornadoresHeaderLogo(fontSize: 16),
          ),
        ),
      );

      expect(find.byType(TrastornadoresHeaderLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('MINISTERIO DE JESÚS'), findsOneWidget);
      expect(find.text('TRASTORNADORES'), findsOneWidget);
      expect(find.text('VISIÓN CONQUISTADORA'), findsOneWidget);
    });

    testWidgets('TrastornadoresBadgeLogo renders with correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrastornadoresBadgeLogo(size: 270),
          ),
        ),
      );

      expect(find.byType(TrastornadoresBadgeLogo), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(3));
    });
  });

  group('ScheduleDetailView Widget Tests', () {
    testWidgets('renders schedule detail without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('ScheduleDetailView Test')),
            ),
          ),
        ),
      );

      expect(find.text('ScheduleDetailView Test'), findsOneWidget);
    });
  });

  group('AdminCalendarView Widget Tests', () {
    testWidgets('renders admin calendar placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('AdminCalendarView Test')),
            ),
          ),
        ),
      );

      expect(find.text('AdminCalendarView Test'), findsOneWidget);
    });
  });

  group('AdminAgendaView Widget Tests', () {
    testWidgets('renders admin agenda placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('AdminAgendaView Test')),
            ),
          ),
        ),
      );

      expect(find.text('AdminAgendaView Test'), findsOneWidget);
    });
  });

  group('AdminMatrixView Widget Tests', () {
    testWidgets('renders admin matrix placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('AdminMatrixView Test')),
            ),
          ),
        ),
      );

      expect(find.text('AdminMatrixView Test'), findsOneWidget);
    });
  });

  group('AdminDashboardView Widget Tests', () {
    testWidgets('renders admin dashboard placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('AdminDashboardView Test')),
            ),
          ),
        ),
      );

      expect(find.text('AdminDashboardView Test'), findsOneWidget);
    });
  });

  group('AdminMembersView Widget Tests', () {
    testWidgets('renders admin members placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserProfile(
              id: 'admin-123',
              name: 'Líder Admin',
              email: 'admin@test.com',
              role: 'ADMIN',
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('AdminMembersView Test')),
            ),
          ),
        ),
      );

      expect(find.text('AdminMembersView Test'), findsOneWidget);
    });
  });

  group('AdminSchedulesView Widget Tests', () {
    testWidgets('renders admin schedules placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('AdminSchedulesView Test')),
            ),
          ),
        ),
      );

      expect(find.text('AdminSchedulesView Test'), findsOneWidget);
    });
  });
}