import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:dio/dio.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/user_provider.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error (likely missing web options): $e');
  }

  final user = await fetchCurrentUser(Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    headers: {'Content-Type': 'application/json'},
  )));

  runApp(ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => user),
    ],
    child: const TrastornadoresApp(),
  ));
}

class TrastornadoresApp extends ConsumerWidget {
  const TrastornadoresApp({super.key});

  // Sistema de Diseño Stitch Light (Blanco, Slate-50, Azul Rey, Dorado)
  static const Color lightBackground = Color(0xFFF7F9FB); // Blanco Slate Canvas
  static const Color royalBlue = Color(0xFF0038A8);      // Azul Rey Oficial
  static const Color goldAccent = Color(0xFFFFC107);     // Dorado Oficial

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TrastornadoresApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: royalBlue,
          primary: royalBlue,
          secondary: goldAccent,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: royalBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF001F5C).withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE0E3E5), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: royalBlue,
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        ],
      ),
      routerConfig: appRouter,
    );
  }
}
