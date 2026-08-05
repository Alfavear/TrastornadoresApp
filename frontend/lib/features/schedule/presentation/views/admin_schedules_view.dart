import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/schedule_model.dart';
import '../providers/schedule_providers.dart';

class AdminSchedulesView extends ConsumerStatefulWidget {
  const AdminSchedulesView({super.key});

  @override
  ConsumerState<AdminSchedulesView> createState() => _AdminSchedulesViewState();
}

class _AdminSchedulesViewState extends ConsumerState<AdminSchedulesView> {
  bool _updating = false;

  Future<void> _toggleSchedule(ScheduleModel schedule, bool isOpen) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await ref
          .read(scheduleRepositoryProvider)
          .updateScheduleStatus(id: schedule.id, isOpen: isOpen);
      ref.invalidate(schedulesProvider);
      _showFeedback(isOpen ? 'Cronograma abierto' : 'Cronograma cerrado');
    } catch (e) {
      _showFeedback('Error al actualizar el estado: $e', isError: true);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _showCreateScheduleDialog() async {
    int month = DateTime.now().month;
    final year = DateTime.now().year;

    final result = await showDialog<({int month, int year})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Cronograma'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: month,
                    decoration: const InputDecoration(labelText: 'Mes'),
                    items: List.generate(12, (i) => i + 1).map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          DateFormat('MMMM', 'es').format(DateTime(year, m)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => month = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: year,
                    decoration: const InputDecoration(labelText: 'Año'),
                    items: [year, year + 1].map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext)
                      .pop((month: month, year: year)),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    try {
      final created =
          await ref.read(scheduleRepositoryProvider).createSchedule(
                month: result.month,
                year: result.year,
              );
      ref.invalidate(schedulesProvider);
      _showFeedback(
        'Cronograma de ${DateFormat('MMMM yyyy', 'es').format(DateTime(created.year, created.month))} creado',
      );
    } catch (e) {
      final message = e.toString().contains('already exists')
          ? 'Ese mes ya tiene un cronograma creado'
          : 'Error al crear el cronograma: $e';
      _showFeedback(message, isError: true);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF0038A8),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return Stack(
      children: [
        scheduleAsync.when(
          data: (schedules) {
            if (schedules.isEmpty) {
              return Center(
                child: Text(
                  'Aún no hay cronogramas. Crea el primero con el botón +.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final monthName = DateFormat('MMMM yyyy', 'es')
                    .format(DateTime(schedule.year, schedule.month))
                    .toUpperCase();

                final answered =
                    schedule.dates.fold<int>(0, (sum, d) => sum + d.availabilities.length);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: schedule.isOpen
                          ? Colors.green.shade200
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                monthName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0038A8),
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                schedule.isOpen ? 'ABIERTO' : 'CERRADO',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: schedule.isOpen
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.event_available,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              '${schedule.dates.length} fechas · $answered respuestas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule.isOpen
                                  ? 'Cerrar inscripciones'
                                  : 'Reabrir inscripciones',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0038A8),
                              ),
                            ),
                            Switch(
                              value: schedule.isOpen,
                              activeTrackColor: Colors.green.shade400,
                              onChanged: _updating
                                  ? null
                                  : (value) => _toggleSchedule(schedule, value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('Error al cargar cronogramas: $err'),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showCreateScheduleDialog,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Cronograma'),
          ),
        ),
      ],
    );
  }
}