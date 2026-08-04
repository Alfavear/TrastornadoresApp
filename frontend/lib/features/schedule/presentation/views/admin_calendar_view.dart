import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/schedule_providers.dart';
import 'package:intl/intl.dart';

class AdminCalendarView extends ConsumerStatefulWidget {
  const AdminCalendarView({super.key});

  @override
  ConsumerState<AdminCalendarView> createState() => _AdminCalendarViewState();
}

class _AdminCalendarViewState extends ConsumerState<AdminCalendarView> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return scheduleAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return _buildEmptyState();
        }

        final currentSchedule = schedules.first;
        final dates = currentSchedule.dates;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Card
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 36, color: Colors.indigo),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cronograma de ${DateFormat('MMMM yyyy', 'es').format(DateTime(currentSchedule.year, currentSchedule.month))}'.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dates.length} fechas programadas (Jue, Sáb, Dom)',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Selecciona una fecha para ver asistentes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),

              // Calendar Grid of active dates
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final dateItem = dates[index];
                  final isSelected = _selectedDate == dateItem.date;
                  final availableCount = dateItem.availabilities
                      .where((a) => a.status == 'PUEDO')
                      .length;
                  final dayName = DateFormat('EEE', 'es').format(dateItem.date).toUpperCase();
                  final dayNum = DateFormat('d').format(dateItem.date);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = dateItem.date;
                      });
                      _showDateDetailsBottomSheet(context, dateItem.date, dateItem.availabilities);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayNum,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white24
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$availableCount dispo.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error al cargar calendario: $err')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No hay ningún cronograma generado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Genera uno nuevo para comenzar a recibir respuestas.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showDateDetailsBottomSheet(
    BuildContext context,
    DateTime date,
    List<dynamic> availabilities,
  ) {
    final availableList = availabilities.where((a) => a.status == 'PUEDO').toList();
    final unavailableList = availabilities.where((a) => a.status == 'NO_PUEDO').toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE d de MMMM', 'es').format(date).toUpperCase(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              
              // Available Section
              Text(
                '✅ Disponibles (${availableList.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 6),
              availableList.isEmpty
                  ? const Text('Ningún integrante confirmado aún', style: TextStyle(color: Colors.grey, fontSize: 13))
                  : Wrap(
                      spacing: 8,
                      children: availableList
                          .map((a) => Chip(
                                avatar: const CircleAvatar(child: Icon(Icons.person, size: 14)),
                                label: Text(a.user?.name ?? 'Usuario'),
                                backgroundColor: Colors.green.shade50,
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 16),

              // Unavailable Section
              Text(
                '❌ No Disponibles (${unavailableList.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 6),
              unavailableList.isEmpty
                  ? const Text('Nadie reportó indisponibilidad', style: TextStyle(color: Colors.grey, fontSize: 13))
                  : Wrap(
                      spacing: 8,
                      children: unavailableList
                          .map((a) => Chip(
                                avatar: const CircleAvatar(child: Icon(Icons.person_off, size: 14)),
                                label: Text(a.user?.name ?? 'Usuario'),
                                backgroundColor: Colors.red.shade50,
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
