import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/schedule_providers.dart';
import 'package:intl/intl.dart';

class AdminAgendaView extends ConsumerWidget {
  const AdminAgendaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return scheduleAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return const Center(child: Text('No hay información de agenda'));
        }

        final currentSchedule = schedules.first;
        final dates = currentSchedule.dates;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final dateItem = dates[index];
            final formattedDate = DateFormat("EEEE d 'de' MMMM", 'es').format(dateItem.date);
            final availableList = dateItem.availabilities.where((a) => a.status == 'PUEDO').toList();
            final unavailableList = dateItem.availabilities.where((a) => a.status == 'NO_PUEDO').toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0038A8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  formattedDate.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  '${availableList.length} confirmados · ${unavailableList.length} ausentes',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // UX Feature: WhatsApp Export Button per date
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.share, size: 18, color: Colors.green),
                            label: const Text('Copiar formato para WhatsApp 📲'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green.shade800,
                              side: BorderSide(color: Colors.green.shade600),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              final textToCopy = _generateWhatsAppText(formattedDate, availableList);
                              Clipboard.setData(ClipboardData(text: textToCopy));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('¡Formato copiado al portapapeles! Pégalo en WhatsApp.'),
                                  backgroundColor: Colors.green.shade800,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Confirmados para servir:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        availableList.isEmpty
                            ? const Text('Ningún voluntario anotado', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                            : Column(
                                children: availableList
                                    .map((a) => ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          leading: const CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.green,
                                            child: Icon(Icons.check, size: 14, color: Colors.white),
                                          ),
                                          title: Text(a.user?.name ?? 'Usuario'),
                                        ))
                                    .toList(),
                              ),
                        const SizedBox(height: 12),
                        const Text(
                          'No disponibles:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        unavailableList.isEmpty
                            ? const Text('Sin ausencias notificadas', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                            : Column(
                                children: unavailableList
                                    .map((a) => ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          leading: const CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.red,
                                            child: Icon(Icons.close, size: 14, color: Colors.white),
                                          ),
                                          title: Text(a.user?.name ?? 'Usuario'),
                                        ))
                                    .toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error al cargar agenda: $err')),
    );
  }

  String _generateWhatsAppText(String formattedDate, List<dynamic> availableList) {
    final buffer = StringBuffer();
    buffer.writeln('🙌 *MINISTERIO DE JESÚS TRASTORNADORES*');
    buffer.writeln('🗓️ *Equipo confirmado para el ${formattedDate.toUpperCase()}:*\n');
    if (availableList.isEmpty) {
      buffer.writeln('_(Aún no hay servidores confirmados)_');
    } else {
      for (var i = 0; i < availableList.length; i++) {
        buffer.writeln('${i + 1}. ${availableList[i].user?.name ?? 'Servidor'}');
      }
    }
    buffer.writeln('\n¡Nos vemos para servir al Señor! 🔥');
    return buffer.toString();
  }
}
