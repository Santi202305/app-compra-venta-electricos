import 'package:flutter/material.dart';

import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Pantalla de ingreso. Por ahora es un formulario simple sin
/// autenticación real: queda pendiente conectarla al backend
/// (Spring Boot) cuando exista el endpoint de login.
class LoginScreen extends StatefulWidget {
  final CartState cartState;
  const LoginScreen({super.key, required this.cartState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(cartState: widget.cartState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.bolt, size: 56, color: AppColors.accent),
              const SizedBox(height: 12),
              Text(
                'Compra y venta de materiales eléctricos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Catálogo, carrito y asistente virtual en un solo lugar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _goToHome,
                child: const Text('Ingresar'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _goToHome,
                child: const Text('Continuar como invitado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
