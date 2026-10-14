import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

class WhatsAppService {
  /// Abre WhatsApp directamente en Web (vía window.open) o en App Móvil
  static Future<bool> openWhatsApp({
    String? phone,
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);
    final String urlString = (phone != null && phone.trim().isNotEmpty)
        ? 'https://wa.me/${phone.replaceAll(RegExp(r'[^\d+]'), '')}?text=$encodedMessage'
        : 'https://api.whatsapp.com/send?text=$encodedMessage';

    try {
      if (kIsWeb) {
        web.window.open(urlString, '_blank');
        return true;
      } else {
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          return await launchUrl(uri);
        }
      }
    } catch (e) {
      debugPrint('Error abriendo WhatsApp: $e');
      if (kIsWeb) {
        web.window.open(urlString, '_blank');
        return true;
      }
      return false;
    }
  }

  /// Genera y envía una alerta de recordatorio individual por WhatsApp
  static Future<bool> sendMemberReminder({
    required String phone,
    required String name,
    required String dateStr,
  }) async {
    final message = '''
🙌 *MINISTERIO DE JESÚS TRASTORNADORES* ✝️
Hola *$name*! 👋

Te recordamos tu servicio para el *$dateStr*.
Por favor confirma tu disponibilidad en la app.

¡Nos vemos en el servicio para glorificar al Señor! 🔥
''';
    return await openWhatsApp(phone: phone, message: message);
  }

  /// Genera y envía el resumen oficial de la fecha al Grupo de WhatsApp
  static Future<bool> sendGroupScheduleSummary({
    required String formattedDate,
    required List<String> confirmedMembers,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('🙌 *MINISTERIO DE JESÚS TRASTORNADORES* ✝️');
    buffer.writeln('📢 *ALERTA DE SERVICIO Y AGENDA*');
    buffer.writeln('🗓️ *Servidores confirmados para el $formattedDate:*\n');

    if (confirmedMembers.isEmpty) {
      buffer.writeln('_(Aún no hay servidores confirmados)_');
    } else {
      for (var i = 0; i < confirmedMembers.length; i++) {
        buffer.writeln('${i + 1}. ${confirmedMembers[i]}');
      }
    }

    buffer.writeln('\n¡Bendiciones a todos! Confirmen su asistencia en la app. 🔥');
    return await openWhatsApp(message: buffer.toString());
  }
}
