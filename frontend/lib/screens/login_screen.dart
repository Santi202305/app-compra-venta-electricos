import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Pantalla de ingreso moderna y flexible para demostraciones y producción.
class LoginScreen extends StatefulWidget {
  final AppState app;
  const LoginScreen({super.key, required this.app});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userInputController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _showTraditional = false;
  bool _registerMode = false;
  String? _error;

  @override
  void dispose() {
    _userInputController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(app: widget.app)),
    );
  }

  void _quickCustomerLogin() {
    widget.app.loginAsCustomer();
    _goToHome();
  }

  void _quickAdminLogin() {
    widget.app.loginAsAdmin();
    _goToHome();
  }

  void _loginFlexible() {
    final input = _userInputController.text.trim();
    widget.app.loginFlexible(identifier: input.isEmpty ? 'Cliente' : input);
    _goToHome();
  }

  void _continueAsGuest() {
    widget.app.logout();
    _goToHome();
  }

  bool _isLoading = false;

  void _fillSeedAdmin() {
    setState(() {
      _showTraditional = true;
      _registerMode = false;
      _emailController.text = 'admin@electroindustrial.com';
      _passwordController.text = 'Admin2026*';
      _error = null;
    });
  }

  void _fillSeedDemo() {
    setState(() {
      _showTraditional = true;
      _registerMode = false;
      _emailController.text = 'demo@electroindustrial.com';
      _passwordController.text = 'Demo2026*';
      _error = null;
    });
  }

  Future<void> _submitTraditional() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? error = _registerMode
          ? await widget.app.register(
              name: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await widget.app.login(_emailController.text, _passwordController.text);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        setState(() => _error = error);
        return;
      }
      _goToHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error inesperado de autenticación: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Branding Industrial
                  Center(
                    child: Container(
                      height: 76,
                      width: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.bolt, size: 44, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'ELECTRO INDUSTRIAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Materiales y Soluciones Eléctricas Certificadas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Tarjeta Principal
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Ingreso al Prototipo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Selecciona un rol o escribe cualquier nombre para entrar de inmediato.',
                          style: TextStyle(fontSize: 13, color: AppColors.mist),
                        ),
                        const SizedBox(height: 18),

                        // Botones de 1 Clic
                        Row(
                          children: [
                            Expanded(
                              child: _QuickRoleCard(
                                title: 'Cliente',
                                subtitle: 'Catálogo y compras',
                                icon: Icons.person_outline,
                                color: const Color(0xFF2563EB),
                                onTap: _quickCustomerLogin,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickRoleCard(
                                title: 'Administrador',
                                subtitle: 'Gestión y pedidos',
                                icon: Icons.admin_panel_settings_outlined,
                                color: const Color(0xFFD97706),
                                onTap: _quickAdminLogin,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'o escribe tu nombre',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Campo libre (sin contraseñas fijas)
                        TextField(
                          controller: _userInputController,
                          decoration: InputDecoration(
                            labelText: 'Nombre o Correo',
                            hintText: 'Ej: Wilson Ortiz o tu@correo.com',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _loginFlexible(),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loginFlexible,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Entrar con este usuario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _continueAsGuest,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Continuar como Invitado'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        // Opción colapsable para login tradicional
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showTraditional = !_showTraditional;
                              _error = null;
                            });
                          },
                          child: Text(
                            _showTraditional
                                ? 'Ocultar login con contraseña'
                                : '¿Prefieres login tradicional con contraseña?',
                            style: const TextStyle(fontSize: 12, color: AppColors.mist),
                          ),
                        ),

                        if (_showTraditional) ...[
                          const SizedBox(height: 10),
                          if (_registerMode) ...[
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nombre completo',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            onSubmitted: (_) => _submitTraditional(),
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              isDense: true,
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitTraditional,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_registerMode ? 'Crear cuenta con JWT' : 'Ingresar con JWT'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Probar usuario:',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: _fillSeedAdmin,
                                child: const Text('Admin', style: TextStyle(fontSize: 11)),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: _fillSeedDemo,
                                child: const Text('Demo', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => setState(() {
                                      _registerMode = !_registerMode;
                                      _error = null;
                                    }),
                            child: Text(
                              _registerMode
                                  ? 'Ya tengo cuenta: ingresar'
                                  : '¿No tienes cuenta? Regístrate',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'UCEVA · Proyecto de Materiales Eléctricos e Industriales',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickRoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.mist),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
