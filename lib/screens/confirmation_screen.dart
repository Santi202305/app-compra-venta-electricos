import 'package:flutter/material.dart';

import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final CartState cartState;
  const ConfirmationScreen({super.key, required this.cartState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 72),
              const SizedBox(height: 16),
              Text('¡Pedido confirmado!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Te avisaremos por notificación cuando tu pedido esté en '
                'camino.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(cartState: cartState),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
