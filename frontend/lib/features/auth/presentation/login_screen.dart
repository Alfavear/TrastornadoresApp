import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/logo_widget.dart';
import 'providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color lightBackground = Color(0xFFF7F9FB);
  static const Color royalBlueDark = Color(0xFF001F5C);
  static const Color royalBlue = Color(0xFF0038A8);
  static const Color goldAccent = Color(0xFFFFC107);

  // 0: Google, 1: Teléfono, 2: Correo
  int _selectedAuthMethod = 0;

  // Controllers Teléfono
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  // Controllers Correo
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Oficial Completo sobre Fondo Blanco Nítido
                const TrastornadoresBadgeLogo(size: 260),

                const SizedBox(height: 16),

                // Card de Login Multimétodo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF001F5C).withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE0E3E5), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: royalBlueDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selecciona tu método preferido para ingresar:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Método de Autenticación (Google / Teléfono / Correo)
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(
                            value: 0,
                            label: Text('Google', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            icon: Icon(Icons.account_circle, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: Text('Teléfono', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            icon: Icon(Icons.phone_android, size: 16),
                          ),
                          ButtonSegment<int>(
                            value: 2,
                            label: Text('Correo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            icon: Icon(Icons.email_outlined, size: 16),
                          ),
                        ],
                        selected: {_selectedAuthMethod},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _selectedAuthMethod = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Formulario Dinámico Según Método Seleccionado
                      if (_selectedAuthMethod == 0) _buildGoogleAuthView(),
                      if (_selectedAuthMethod == 1) _buildPhoneAuthView(),
                      if (_selectedAuthMethod == 2) _buildEmailAuthView(),

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE0E3E5), height: 1),
                      const SizedBox(height: 12),

                      // Enlace Azul Rey al pie para acceso de Administradores
                      TextButton.icon(
                        icon: const Icon(Icons.verified_user_outlined, size: 16, color: royalBlue),
                        label: const Text(
                          'Acceso a Panel de Administración (Líder)',
                          style: TextStyle(
                            fontSize: 12,
                            color: royalBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          ref.read(currentUserProvider.notifier).state = UserProfile(
                            id: 'admin-google-123',
                            name: 'Líder Administrador',
                            email: 'admin@trastornadores.org',
                            role: 'ADMIN',
                          );
                          context.go('/admin');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  '© Ministerio de Jesús Trastornadores 2026',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Vista Método 0: Google Sign-In con Icono confiable
  Widget _buildGoogleAuthView() {
    return Column(
      children: [
        Text(
          'Ingreso rápido con un solo toque utilizando tu cuenta oficial de Google.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: royalBlue,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              final partialProfile = UserProfile(
                id: 'servidor-google-123',
                name: 'Servidor Trastornador',
                email: 'servidor@trastornadores.org',
                role: 'PARTICIPANT',
              );
              _promptForPhoneNumber(partialProfile);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Image.network(
                    'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                    height: 18,
                    width: 18,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 20, color: royalBlue),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Continuar con Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneAuthView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Número de Teléfono (+57 ...)',
            prefixIcon: const Icon(Icons.phone, color: royalBlue, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nombre Completo',
            prefixIcon: const Icon(Icons.person_outline, color: royalBlue, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.app_registration, size: 18),
            label: const Text('Registrarse con Teléfono', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: royalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              final name = _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : 'Servidor Móvil';
              final phone = _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : '+57 300 000 0000';

              ref.read(currentUserProvider.notifier).state = UserProfile(
                id: 'phone-${phone.replaceAll(' ', '')}',
                name: name,
                email: '${phone.replaceAll(' ', '')}@trastornadores.org',
                phone: phone,
                role: 'PARTICIPANT',
              );
              context.go('/schedule');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailAuthView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            prefixIcon: const Icon(Icons.email_outlined, color: royalBlue, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline, color: royalBlue, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Iniciar Sesión con Correo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: royalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              final email = _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : 'servidor@trastornadores.org';
              final name = email.contains('@') ? email.split('@').first : 'Servidor';

              final partialProfile = UserProfile(
                id: 'email-${email.hashCode}',
                name: name.toUpperCase(),
                email: email,
                role: 'PARTICIPANT',
              );
              _promptForPhoneNumber(partialProfile);
            },
          ),
        ),
      ],
    );
  }

  void _promptForPhoneNumber(UserProfile partialProfile) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Completa tu Perfil',
            style: TextStyle(color: royalBlueDark, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para enviarte alertas automáticas necesitamos tu número de WhatsApp.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número (Ej. +57 300...)',
                  prefixIcon: const Icon(Icons.chat, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: royalBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final phone = phoneController.text.trim();
                if (phone.isEmpty) return;

                // Actualizar profile con teléfono
                final completeProfile = UserProfile(
                  id: partialProfile.id,
                  name: partialProfile.name,
                  email: partialProfile.email,
                  phone: phone,
                  photoUrl: partialProfile.photoUrl,
                  role: partialProfile.role,
                );

                Navigator.pop(context);
                ref.read(currentUserProvider.notifier).state = completeProfile;
                context.go('/schedule');
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }
}

