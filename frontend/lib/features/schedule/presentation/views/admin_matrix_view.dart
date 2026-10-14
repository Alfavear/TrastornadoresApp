import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/schedule_providers.dart';
import 'package:intl/intl.dart';

class AdminMatrixView extends ConsumerStatefulWidget {
  const AdminMatrixView({super.key});

  @override
  ConsumerState<AdminMatrixView> createState() => _AdminMatrixViewState();
}

class _AdminMatrixViewState extends ConsumerState<AdminMatrixView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(schedulesProvider);

    return scheduleAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return const Center(child: Text('No hay datos para la matriz'));
        }

        final currentSchedule = schedules.first;
        final dates = currentSchedule.dates;

        // Extract all unique users who responded across dates
        final Map<String, String> userNames = {};
        for (var d in dates) {
          for (var a in d.availabilities) {
            if (a.user != null) {
              userNames[a.userId] = a.user!.name;
            }
          }
        }

        final filteredUsers = userNames.entries
            .where((e) => e.value.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Input Filter
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar integrante por nombre...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Scrollable Excel Matrix
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                        columns: [
                          const DataColumn(
                            label: Text(
                              'Integrante',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                          ),
                          ...dates.map(
                            (d) => DataColumn(
                              label: Center(
                                child: Text(
                                  DateFormat('dd/MM\n(EEE)', 'es').format(d.date).toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: filteredUsers.isEmpty
                            ? [
                                DataRow(
                                  cells: [
                                    const DataCell(Text('Sin registros')),
                                    ...dates.map((_) => const DataCell(Text('-'))),
                                  ],
                                )
                              ]
                            : filteredUsers.map((userEntry) {
                                final userId = userEntry.key;
                                final userName = userEntry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        userName,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    ...dates.map((d) {
                                      final userAvailability = d.availabilities
                                          .where((a) => a.userId == userId)
                                          .firstOrNull;

                                      if (userAvailability == null) {
                                        return const DataCell(
                                          Center(child: Text('➖', style: TextStyle(color: Colors.grey))),
                                        );
                                      }

                                      final isAvailable = userAvailability.status == 'PUEDO';
                                      return DataCell(
                                        Center(
                                          child: Text(
                                            isAvailable ? '✅' : '❌',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error en la matriz: $err')),
    );
  }
}
