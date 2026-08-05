import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/user_provider.dart';

class MemberUser {
  final String id;
  final String name;
  final String email;
  String role; // 'PARTICIPANT' or 'ADMIN'

  MemberUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AdminMembersView extends ConsumerStatefulWidget {
  const AdminMembersView({super.key});

  @override
  ConsumerState<AdminMembersView> createState() => _AdminMembersViewState();
}

class _AdminMembersViewState extends ConsumerState<AdminMembersView> {
  final List<MemberUser> _members = [
    MemberUser(id: 'servidor-1', name: 'Servidor Trastornador', email: 'servidor@trastornadores.org', role: 'PARTICIPANT'),
    MemberUser(id: 'admin-1', name: 'Líder Administrador', email: 'admin@trastornadores.org', role: 'ADMIN'),
    MemberUser(id: 'servidor-2', name: 'Mateo González', email: 'mateo@trastornadores.org', role: 'PARTICIPANT'),
    MemberUser(id: 'servidor-3', name: 'Sofía Rodríguez', email: 'sofia@trastornadores.org', role: 'PARTICIPANT'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTROL DE ACCESO Y ROLES',
              style: TextStyle(
                color: Color(0xFF0038A8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gestión de Permisos de Miembros',
              style: TextStyle(
                color: Color(0xFF001F5C),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Asigna permisos de Líder Administrador o Miembro Servidor a los integrantes registrados con cuenta Google.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  final isAdmin = member.role == 'ADMIN';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isAdmin ? const Color(0xFFFFC107) : const Color(0xFFE0E3E5),
                        width: isAdmin ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: isAdmin ? const Color(0xFFFFC107) : const Color(0xFF0038A8),
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: TextStyle(
                                color: isAdmin ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF001F5C),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  member.email,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Permiso de Acceso:',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              DropdownButton<String>(
                                value: member.role,
                                underline: const SizedBox(),
                                isDense: true,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'PARTICIPANT',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 14, color: Color(0xFF0038A8)),
                                        SizedBox(width: 6),
                                        Text('Miembro Servidor', style: TextStyle(color: Color(0xFF0038A8))),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ADMIN',
                                    child: Row(
                                      children: [
                                        Icon(Icons.security, size: 14, color: Colors.amber),
                                        SizedBox(width: 6),
                                        Text('Líder Admin', style: TextStyle(color: Colors.amber)),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (newRole) {
                                  if (newRole != null) {
                                    setState(() {
                                      member.role = newRole;
                                    });
                                    if (currentUser.email == member.email) {
                                      ref.read(currentUserProvider.notifier).state = UserProfile(
                                        id: member.id,
                                        name: member.name,
                                        email: member.email,
                                        role: newRole,
                                      );
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Permiso de ${member.name} actualizado a ${newRole == 'ADMIN' ? 'Líder Admin' : 'Miembro Servidor'}'),
                                        backgroundColor: const Color(0xFF0038A8),
                                      ),
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
        ),
      ),
    );
  }
}
