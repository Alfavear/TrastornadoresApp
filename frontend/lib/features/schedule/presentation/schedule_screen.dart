import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'providers/schedule_providers.dart';
import '../../auth/presentation/providers/user_provider.dart';
import '../../../core/widgets/logo_widget.dart';
import 'views/admin_agenda_view.dart';
import 'views/admin_calendar_view.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _currentBottomNavIndex = 0;
  String? _expandedScheduleId;
  final Map<String, String?> _userSelections = {};

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(schedulesProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0038A8),
        elevation: 0,
        title: const TrastornadoresHeaderLogo(fontSize: 14),
        centerTitle: true,
        actions: [
          if (user.role == 'ADMIN')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFFFC107)),
              tooltip: 'Panel de Administración',
              onPressed: () => context.go('/admin'),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),

      // Menú Lateral Desplegable (100% Español)
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Encabezado del Perfil
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F9FB),
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E3E5), width: 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0038A8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0038A8), width: 1),
                      ),
                      child: const Text(
                        'TRASTORNADORES',
                        style: TextStyle(
                          color: Color(0xFF0038A8),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF0038A8),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Color(0xFF001F5C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.role == 'ADMIN' ? 'Líder Administrador' : 'Servidor Activo',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Opciones del Menú en Español
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _buildDrawerItem(Icons.home_outlined, 'Inicio / Bandeja', _currentBottomNavIndex == 0, () {
                      Navigator.pop(context);
                      setState(() => _currentBottomNavIndex = 0);
                    }),
                    _buildDrawerItem(Icons.calendar_month_outlined, 'Calendario de Servicio', _currentBottomNavIndex == 1, () {
                      Navigator.pop(context);
                      setState(() => _currentBottomNavIndex = 1);
                    }),
                    _buildDrawerItem(Icons.view_agenda_outlined, 'Agenda de Servicios', _currentBottomNavIndex == 2, () {
                      Navigator.pop(context);
                      setState(() => _currentBottomNavIndex = 2);
                    }),
                    _buildDrawerItem(Icons.account_circle_outlined, 'Mi Perfil de Usuario', _currentBottomNavIndex == 3, () {
                      Navigator.pop(context);
                      setState(() => _currentBottomNavIndex = 3);
                    }),
                    const Divider(color: Color(0xFFE0E3E5)),
                    _buildDrawerItem(Icons.logout, 'Cerrar Sesión', false, () => context.go('/login')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Cuerpo dinámico de vistas
      body: _buildCurrentView(scheduleAsync, user),

      // Barra de Navegación Inferior (100% Español)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        selectedItemColor: const Color(0xFF0038A8),
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.church), label: 'Servicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildCurrentView(AsyncValue<List<dynamic>> scheduleAsync, dynamic user) {
    switch (_currentBottomNavIndex) {
      case 1:
        return const AdminCalendarView();
      case 2:
        return const AdminAgendaView();
      case 3:
        return _buildEnhancedProfileView(scheduleAsync, user);
      case 0:
      default:
        return _buildInboxView(scheduleAsync, user);
    }
  }

  // Vista de Bandeja Principal (100% Español)
  Widget _buildInboxView(AsyncValue<List<dynamic>> scheduleAsync, dynamic user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BANDEJA DE CRONOGRAMAS',
              style: TextStyle(
                color: Color(0xFF0038A8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coordinación Ministerial',
              style: TextStyle(
                color: Color(0xFF001F5C),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Revisa y responde a tus fechas de servicio para mantener organizada nuestra labor ministerial.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Lista de Tarjetas de Cronogramas
            scheduleAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E3E5)),
                    ),
                    child: const Center(
                      child: Text(
                        'No hay cronogramas activos en este momento',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                _expandedScheduleId ??= schedules.first.id;

                return Column(
                  children: schedules.map((schedule) {
                    final isExpanded = _expandedScheduleId == schedule.id;
                    final monthName = DateFormat('MMMM yyyy', 'es')
                        .format(DateTime(schedule.year, schedule.month))
                        .toUpperCase();
                    final dates = schedule.dates;
                    final totalDates = dates.length;
                    final isOpen = schedule.isOpen;

                    int answeredCount = 0;
                    for (var d in dates) {
                      final userAv = d.availabilities.firstWhere(
                        (a) => a.userId == user.id || a.user?.email == user.email,
                        orElse: () => null,
                      );
                      final currentSel = _userSelections[d.id] ?? userAv?.status;
                      if (currentSel != null && currentSel.isNotEmpty) {
                        answeredCount++;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF001F5C).withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isOpen ? const Color(0xFF0038A8) : const Color(0xFFE0E3E5),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                _expandedScheduleId = isExpanded ? null : schedule.id;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        monthName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF001F5C),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isOpen ? Colors.green.shade50 : Colors.amber.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isOpen ? Colors.green.shade300 : Colors.amber.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              isOpen ? 'ABIERTO' : 'CERRADO',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isOpen ? Colors.green.shade800 : Colors.amber.shade900,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                            color: const Color(0xFF0038A8),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$totalDates Fechas de Servicio Programadas',
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: totalDates > 0 ? (answeredCount / totalDates) : 0.0,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0038A8)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$answeredCount de $totalDates respondidas',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        isExpanded ? 'Ocultar Fechas ▲' : 'Responder / Ver Fechas ▼',
                                        style: const TextStyle(
                                          color: Color(0xFF0038A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (isExpanded) ...[
                            const Divider(height: 1),
                            Container(
                              color: const Color(0xFFF7F9FB),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isOpen)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.amber.shade200),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.info_outline, size: 16, color: Colors.amber),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Cronograma cerrado para ediciones. Modo solo consulta.',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ...dates.map((dateModel) {
                                    final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(dateModel.date);
                                    
                                    String serviceTitle = 'Servicio General';
                                    String serviceTime = '19:30 - 21:30';
                                    IconData serviceIcon = Icons.menu_book;

                                    if (dateModel.date.weekday == DateTime.saturday) {
                                      serviceTitle = 'Reunión de Jóvenes';
                                      serviceTime = '18:00 - 20:00';
                                      serviceIcon = Icons.local_fire_department;
                                    } else if (dateModel.date.weekday == DateTime.sunday) {
                                      serviceTitle = 'Servicios Dominicales';
                                      serviceTime = '09:00 - 14:00';
                                      serviceIcon = Icons.church;
                                    }

                                    final existingAv = dateModel.availabilities.firstWhere(
                                      (a) => a.userId == user.id || a.user?.email == user.email,
                                      orElse: () => null,
                                    );
                                    final currentSelection = _userSelections[dateModel.id] ?? existingAv?.status;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE0E3E5)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(serviceIcon, color: const Color(0xFF0038A8), size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  dateStr.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0038A8),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                serviceTime,
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            serviceTitle,
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                          ),
                                          const SizedBox(height: 10),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ChoiceChip(
                                                label: const Text('Puedo'),
                                                selected: currentSelection == 'PUEDO',
                                                selectedColor: Colors.green.shade600,
                                                labelStyle: TextStyle(
                                                  color: currentSelection == 'PUEDO' ? Colors.white : Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                                onSelected: isOpen
                                                    ? (selected) async {
                                                        final newStatus = selected ? 'PUEDO' : null;
                                                        setState(() {
                                                          _userSelections[dateModel.id] = newStatus;
                                                        });
                                                        if (newStatus != null) {
                                                          await ref.read(scheduleRepositoryProvider).registerAvailability(
                                                                scheduleDateId: dateModel.id,
                                                                status: 'PUEDO',
                                                              );
                                                          _showToast('¡Disponibilidad registrada!');
                                                        }
                                                      }
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              ChoiceChip(
                                                label: const Text('No Puedo'),
                                                selected: currentSelection == 'NO_PUEDO',
                                                selectedColor: Colors.red.shade400,
                                                labelStyle: TextStyle(
                                                  color: currentSelection == 'NO_PUEDO' ? Colors.white : Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                                onSelected: isOpen
                                                    ? (selected) async {
                                                        final newStatus = selected ? 'NO_PUEDO' : null;
                                                        setState(() {
                                                          _userSelections[dateModel.id] = newStatus;
                                                        });
                                                        if (newStatus != null) {
                                                          await ref.read(scheduleRepositoryProvider).registerAvailability(
                                                                scheduleDateId: dateModel.id,
                                                                status: 'NO_PUEDO',
                                                              );
                                                          _showToast('Respuesta guardada');
                                                        }
                                                      }
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF0038A8)),
                ),
              ),
              error: (err, stack) => Text(
                'Error al cargar cronogramas: $err',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'HORARIOS DE SERVICIO DE REFERENCIA',
              style: TextStyle(
                color: Color(0xFF0038A8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            _buildServiceTimingCard(
              icon: Icons.menu_book,
              title: 'Jueves - Servicio General',
              time: '19:30 - 21:30',
            ),
            _buildServiceTimingCard(
              icon: Icons.local_fire_department,
              title: 'Sábado - Reunión de Jóvenes',
              time: '18:00 - 20:00',
            ),
            _buildServiceTimingCard(
              icon: Icons.church,
              title: 'Domingo - Servicios Dominicales',
              time: '09:00 - 14:00',
            ),
          ],
        ),
      ),
    );
  }

  // Vista de Perfil Mejorada (100% Español)
  Widget _buildEnhancedProfileView(AsyncValue<List<dynamic>> scheduleAsync, dynamic user) {
    int confirmedCount = _userSelections.values.where((v) => v == 'PUEDO').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Tarjeta de Perfil Principal
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF001F5C).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE0E3E5)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFF0038A8),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Color(0xFF001F5C),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 14),

                // Badge de Rol Ministerial
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.role == 'ADMIN'
                        ? const Color(0xFFFFC107).withValues(alpha: 0.2)
                        : const Color(0xFF0038A8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: user.role == 'ADMIN' ? const Color(0xFFFFC107) : const Color(0xFF0038A8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.role == 'ADMIN' ? Icons.security : Icons.person_outline,
                        size: 14,
                        color: user.role == 'ADMIN' ? Colors.amber.shade900 : const Color(0xFF0038A8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.role == 'ADMIN' ? 'ADMINISTRADOR MINISTERIAL' : 'SERVIDOR DE DISPONIBILIDAD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: user.role == 'ADMIN' ? Colors.amber.shade900 : const Color(0xFF0038A8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Grilla de Estadísticas de Disponibilidad
          Row(
            children: [
              Expanded(
                child: _buildProfileStatTile(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  value: '$confirmedCount',
                  label: 'Servicios Confirmados',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileStatTile(
                  icon: Icons.verified_user_outlined,
                  color: const Color(0xFF0038A8),
                  value: user.role == 'ADMIN' ? 'Líder' : 'Servidor',
                  label: 'Nivel de Cuenta',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botones de Acción del Perfil
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.sync_alt, size: 18),
              label: Text(
                user.role == 'ADMIN' ? 'Cambiar a Modo Servidor' : 'Cambiar a Modo Administrador',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0038A8),
                side: const BorderSide(color: Color(0xFF0038A8), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final newRole = user.role == 'ADMIN' ? 'PARTICIPANT' : 'ADMIN';
                ref.read(currentUserProvider.notifier).state = UserProfile(
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  role: newRole,
                );
                _showToast('Perfil actualizado a $newRole');
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go('/login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E3E5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001F5C).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001F5C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF0038A8) : Colors.grey.shade600,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0038A8) : const Color(0xFF001F5C),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF0038A8).withValues(alpha: 0.08),
      onTap: onTap,
    );
  }

  Widget _buildServiceTimingCard({
    required IconData icon,
    required String title,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0038A8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF001F5C), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0038A8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
