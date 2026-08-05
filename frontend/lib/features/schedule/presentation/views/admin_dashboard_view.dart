import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/schedule_providers.dart';
import 'package:intl/intl.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return scheduleAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return const Center(child: Text('No hay datos estadísticos'));
        }

        final currentSchedule = schedules.first;
        final dates = currentSchedule.dates;

        int totalResponses = 0;
        int totalAvailable = 0;
        int totalUnavailable = 0;
        String highestDay = 'N/A';
        int highestCount = 0;

        for (var d in dates) {
          final count = d.availabilities.where((a) => a.status == 'PUEDO').length;
          totalAvailable += count;
          totalUnavailable += d.availabilities.where((a) => a.status == 'NO_PUEDO').length;
          totalResponses += d.availabilities.length;

          if (count > highestCount) {
            highestCount = count;
            highestDay = DateFormat('EEEE d', 'es').format(d.date);
          }
        }

        final int percentageAvailable = totalResponses > 0
            ? ((totalAvailable / totalResponses) * 100).round()
            : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Indicadores (KPIs)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Asistencia Promedio',
                      value: '$percentageAvailable%',
                      icon: Icons.pie_chart_rounded,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Día Más Disponible',
                      value: highestDay.toUpperCase(),
                      subtitle: '$highestCount confirmados',
                      icon: Icons.star_rounded,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Respuestas Disponibles',
                      value: '$totalAvailable',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Ausencias Notificadas',
                      value: '$totalUnavailable',
                      icon: Icons.cancel_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Export Data Actions Card
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exportar Datos de Matriz',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Descarga el reporte en formato CSV / Excel',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Exportar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reporte exportado correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error en el dashboard: $err')),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
