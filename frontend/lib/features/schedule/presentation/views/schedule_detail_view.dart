import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/schedule_model.dart';
import '../providers/schedule_providers.dart';
import '../../../auth/presentation/providers/user_provider.dart';

class ScheduleDetailView extends ConsumerStatefulWidget {
  final ScheduleModel schedule;

  const ScheduleDetailView({
    super.key,
    required this.schedule,
  });

  @override
  ConsumerState<ScheduleDetailView> createState() => _ScheduleDetailViewState();
}

class _ScheduleDetailViewState extends ConsumerState<ScheduleDetailView> {
  final Map<String, String?> _userSelections = {};

  @override
  void initState() {
    super.initState();
    _loadExistingUserSelections();
  }

  void _loadExistingUserSelections() {
    final user = ref.read(currentUserProvider);
    for (var dateModel in widget.schedule.dates) {
      final userAv = dateModel.availabilities.firstWhere(
        (a) => a.userId == user.id || a.user?.email == user.email,
        orElse: () => const AvailabilityModel(
          id: '',
          userId: '',
          scheduleDateId: '',
          status: '',
        ),
      );
      if (userAv.status.isNotEmpty) {
        _userSelections[dateModel.id] = userAv.status;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isOpen = widget.schedule.isOpen;
    final dates = widget.schedule.dates;
    final monthName = DateFormat('MMMM yyyy', 'es')
        .format(DateTime(widget.schedule.year, widget.schedule.month))
        .toUpperCase();

    final totalDates = dates.length;
    final answeredCount = _userSelections.values.where((v) => v != null && v.isNotEmpty).length;
    final progressRatio = totalDates > 0 ? (answeredCount / totalDates) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(monthName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner de Estado & Perfil
          Container(
            color: isOpen ? Colors.green.shade50 : Colors.amber.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isOpen ? Icons.lock_open : Icons.lock_outline,
                  color: isOpen ? Colors.green.shade700 : Colors.amber.shade900,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOpen ? 'Cronograma Abierto' : 'Cronograma Cerrado (Modo Consulta)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.green.shade900 : Colors.amber.shade900,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Servidor: ${user.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    isOpen ? 'EDICIÓN' : 'LECTURA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: isOpen ? Colors.green.shade700 : Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          // Barra de Progreso
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tu respuesta:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$answeredCount de $totalDates respondidos',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF0038A8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0038A8)),
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción masiva (solo si está abierto)
          if (isOpen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.done_all, size: 16, color: Colors.green),
                      label: const Text('Marcar todos PUEDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade800,
                        side: BorderSide(color: Colors.green.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          for (var d in dates) {
                            _userSelections[d.id] = 'PUEDO';
                            ref.read(scheduleRepositoryProvider).registerAvailability(
                              scheduleDateId: d.id,
                              status: 'PUEDO',
                            );
                          }
                        });
                        _showWarmFeedback('¡Gran disposición a servir! 🙌');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.wb_sunny_outlined, size: 16, color: Color(0xFF0038A8)),
                      label: const Text('Solo Domingos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0038A8),
                        side: const BorderSide(color: Color(0xFF0038A8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          for (var d in dates) {
                            final isSunday = d.date.weekday == DateTime.sunday;
                            final status = isSunday ? 'PUEDO' : 'NO_PUEDO';
                            _userSelections[d.id] = status;
                            ref.read(scheduleRepositoryProvider).registerAvailability(
                              scheduleDateId: d.id,
                              status: status,
                            );
                          }
                        });
                        _showWarmFeedback('Disponibilidad de Domingos guardada');
                      },
                    ),
                  ),
                ],
              ),
            ),

          const Divider(),

          // Lista de Fechas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final dateModel = dates[index];
                final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(dateModel.date);
                final currentSelection = _userSelections[dateModel.id];

                return Card(
                  elevation: 1.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            dateStr.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0038A8),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Puedo'),
                              selected: currentSelection == 'PUEDO',
                              selectedColor: Colors.green.shade600,
                              labelStyle: TextStyle(
                                color: currentSelection == 'PUEDO' ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: isOpen
                                  ? (selected) {
                                      setState(() {
                                        if (selected) {
                                          _userSelections[dateModel.id] = 'PUEDO';
                                          ref.read(scheduleRepositoryProvider).registerAvailability(
                                                scheduleDateId: dateModel.id,
                                                status: 'PUEDO',
                                              );
                                          _showWarmFeedback('¡Guardado!');
                                        } else {
                                          _userSelections[dateModel.id] = null;
                                        }
                                      });
                                    }
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text('No Puedo'),
                              selected: currentSelection == 'NO_PUEDO',
                              selectedColor: Colors.red.shade400,
                              labelStyle: TextStyle(
                                color: currentSelection == 'NO_PUEDO' ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: isOpen
                                  ? (selected) {
                                      setState(() {
                                        if (selected) {
                                          _userSelections[dateModel.id] = 'NO_PUEDO';
                                          ref.read(scheduleRepositoryProvider).registerAvailability(
                                                scheduleDateId: dateModel.id,
                                                status: 'NO_PUEDO',
                                              );
                                        } else {
                                          _userSelections[dateModel.id] = null;
                                        }
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWarmFeedback(String message) {
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
