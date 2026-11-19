import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/order_card.dart';

/// Historial de pedidos del usuario con sesión iniciada.
class OrdersScreen extends StatelessWidget {
  final AppState app;
  const OrdersScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          if (!app.isLoggedIn) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 52, color: AppColors.mist),
                    const SizedBox(height: 14),
                    const Text(
                      'Historial para Usuarios Registrados',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Para guardar y revisar tu historial de compras en cualquier momento, ingresa con tu cuenta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.mist),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => app.loginAsCustomer(),
                      child: const Text('Acceder como Cliente para ver pedidos'),
                    ),
                  ],
                ),
              ),
            );
          }
          final orders = app.myOrders;
          if (orders.isEmpty) {
            return const _EmptyMessage(
              icon: Icons.receipt_long_outlined,
              title: 'Aún no tienes pedidos',
              subtitle: 'Cuando compres algo, aparecerá aquí.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: orders.map((o) => OrderCard(order: o)).toList(),
          );
        },
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.mist),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
