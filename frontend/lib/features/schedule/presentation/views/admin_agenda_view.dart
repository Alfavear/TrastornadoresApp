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
                    color: const Color(0xFF001F5C).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE0E3E5)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF001F5C)),
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
                        // Acciones WhatsApp Directas
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.send, size: 16),
                                label: const Text('Enviar Alerta a WhatsApp 📲', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  try {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Enviando alertas automáticas...')),
                                    );
                                    await ref.read(scheduleRepositoryProvider).notifyGroup(dateItem.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('¡Alertas enviadas exitosamente desde el servidor!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al enviar alertas: $e'), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Color(0xFF0038A8)),
                              tooltip: 'Copiar texto',
                              onPressed: () {
                                final confirmedNames = availableList.map((a) => a.user?.name ?? 'Servidor').toList();
                                final text = _generateWhatsAppText(formattedDate, confirmedNames);
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Texto de WhatsApp copiado al portapapeles!'),
                                    backgroundColor: Color(0xFF0038A8),
                                  ),
                                );
                              },
                            ),
                          ],
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
                                children: availableList.map((a) {
                                  final userName = a.user?.name ?? 'Servidor';
                                  final userPhone = a.user?.email.contains('@') == false ? a.user?.email : null;

                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.check, size: 14, color: Colors.white),
                                    ),
                                    title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.mark_chat_unread_outlined, color: Colors.green, size: 20),
                                      tooltip: 'Enviar Recordatorio WhatsApp',
                                      onPressed: () async {
                                        try {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Enviando recordatorio a $userName...')),
                                          );
                                          await ref.read(scheduleRepositoryProvider).notifyReminder(dateItem.id, a.user!.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('¡Recordatorio enviado exitosamente!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
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

  String _generateWhatsAppText(String formattedDate, List<String> availableList) {
    final buffer = StringBuffer();
    buffer.writeln('🙌 *MINISTERIO DE JESÚS TRASTORNADORES* ✝️');
    buffer.writeln('🗓️ *Equipo confirmado para el ${formattedDate.toUpperCase()}:*\n');
    if (availableList.isEmpty) {
      buffer.writeln('_(Aún no hay servidores confirmados)_');
    } else {
      for (var i = 0; i < availableList.length; i++) {
        buffer.writeln('${i + 1}. ${availableList[i]}');
      }
    }
    buffer.writeln('\n¡Nos vemos para servir al Señor! 🔥');
    return buffer.toString();
  }
}
