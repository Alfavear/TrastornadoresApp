import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/schedule_providers.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/logo_widget.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  // Local state map to track selections before/during submission
  final Map<String, String> _userSelections = {};

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TrastornadoresHeaderLogo(fontSize: 14),
        centerTitle: true,
      ),
      body: scheduleAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('No hay cronogramas activos'));
          }
          final currentSchedule = schedules.first;
          final dates = currentSchedule.dates;

          final answeredCount = _userSelections.length;
          final totalDates = dates.length;
          final progressRatio = totalDates > 0 ? (answeredCount / totalDates) : 0.0;

          return Column(
            children: [
              // UX Enhancement 1: Progress Header
              Container(
                color: const Color(0xFF0038A8).withOpacity(0.06),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tu Progreso del Mes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$answeredCount de $totalDates respondidos',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF0038A8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0038A8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // UX Enhancement 2: Bulk Action Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.done_all, size: 16, color: Colors.white),
                            label: const Text('Marcar todos: PUEDO'),
                            backgroundColor: Colors.green.shade700,
                            labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            onPressed: () {
                              setState(() {
                                for (var d in dates) {
                                  _userSelections[d.id] = 'PUEDO';
                                }
                              });
                              _showWarmFeedback(context, '¡Excelente disposición a servir todos los días! 🙌');
                            },
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.white),
                            label: const Text('Marcar solo Domingos'),
                            backgroundColor: const Color(0xFF0038A8),
                            labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            onPressed: () {
                              setState(() {
                                for (var d in dates) {
                                  final isSunday = d.date.weekday == DateTime.sunday;
                                  _userSelections[d.id] = isSunday ? 'PUEDO' : 'NO_PUEDO';
                                }
                              });
                              _showWarmFeedback(context, 'Disponibilidad de Domingos registrada');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Date List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final dateModel = dates[index];
                    final dateStr = DateFormat('EEEE d de MMMM', 'es').format(dateModel.date);
                    final currentSelection = _userSelections[dateModel.id];

                    return Card(
                      elevation: 1.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dateStr.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14, 
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
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _userSelections[dateModel.id] = 'PUEDO';
                                      });
                                      ref.read(scheduleRepositoryProvider).registerAvailability(
                                        scheduleDateId: dateModel.id, 
                                        status: 'PUEDO',
                                      );
                                      _showWarmFeedback(context, '¡Gracias por disponer tu tiempo! 🙌');
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('No Puedo'),
                                  selected: currentSelection == 'NO_PUEDO',
                                  selectedColor: Colors.red.shade400,
                                  labelStyle: TextStyle(
                                    color: currentSelection == 'NO_PUEDO' ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _userSelections[dateModel.id] = 'NO_PUEDO';
                                      });
                                      ref.read(scheduleRepositoryProvider).registerAvailability(
                                        scheduleDateId: dateModel.id, 
                                        status: 'NO_PUEDO',
                                      );
                                    }
                                  },
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showWarmFeedback(BuildContext context, String message) {
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
