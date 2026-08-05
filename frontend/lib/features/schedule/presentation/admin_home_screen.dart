import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/admin_calendar_view.dart';
import 'views/admin_agenda_view.dart';
import 'views/admin_matrix_view.dart';
import 'views/admin_dashboard_view.dart';
import 'views/admin_members_view.dart';
import '../../../core/widgets/logo_widget.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const AdminCalendarView(),
    const AdminAgendaView(),
    const AdminMatrixView(),
    const AdminDashboardView(),
    const AdminMembersView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrastornadoresHeaderLogo(fontSize: 14),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.inbox),
            tooltip: 'Vista Servidor',
            onPressed: () => context.go('/schedule'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: _views[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          NavigationDestination(icon: Icon(Icons.view_agenda), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.grid_on), label: 'Matriz'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.manage_accounts), label: 'Permisos'),
        ],
      ),
    );
  }
}