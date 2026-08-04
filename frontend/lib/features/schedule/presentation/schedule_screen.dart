import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/schedule_providers.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/logo_widget.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TrastornadoresHeaderLogo(fontSize: 14), // Logo en letras en el AppBar al iniciar
        centerTitle: true,
      ),
      body: scheduleAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('No hay cronogramas activos'));
          }
          final currentSchedule = schedules.first;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentSchedule.dates.length,
            itemBuilder: (context, index) {
              final dateModel = currentSchedule.dates[index];
              final dateStr = DateFormat('EEEE d', 'es').format(dateModel.date);
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0038A8),
                        ),
                      ),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Puedo'),
                            selected: false,
                            selectedColor: Colors.green.shade200,
                            onSelected: (val) {
                              if (val) {
                                ref.read(scheduleRepositoryProvider).registerAvailability(
                                  scheduleDateId: dateModel.id, 
                                  status: 'PUEDO'
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('No Puedo'),
                            selected: false,
                            selectedColor: Colors.red.shade200,
                            onSelected: (val) {
                              if (val) {
                                ref.read(scheduleRepositoryProvider).registerAvailability(
                                  scheduleDateId: dateModel.id, 
                                  status: 'NO_PUEDO'
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
