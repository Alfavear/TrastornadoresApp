import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronograma de Disponibilidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecciona tu disponibilidad',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // TODO: Fetch schedule from API and show a list of dates
            const Text('No hay cronogramas abiertos actualmente.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Mock registration
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tu disponibilidad fue registrada correctamente.')),
                );
              },
              child: const Text('Guardar disponibilidad'),
            )
          ],
        ),
      ),
    );
  }
}
