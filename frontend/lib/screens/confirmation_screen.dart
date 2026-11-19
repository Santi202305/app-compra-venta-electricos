import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/secure_sales_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/voucher_dialog.dart';
import 'home_screen.dart';
import 'orders_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final AppState app;
  final Order order;
  final SaleVoucher? voucher;

  const ConfirmationScreen({
    super.key,
    required this.app,
    required this.order,
    this.voucher,
  });

  @override
  Widget build(BuildContext context) {
    final activeVoucher = voucher ?? SecureSalesService.instance.getVoucherForOrder(order.id);
    final email = activeVoucher?.customerEmail ?? (app.currentUser?.email ?? 'cliente@correo.com');

    return Scaffold(
      backgroundColor: AppColors.mistLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Venta Aprobada y Encriptada!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tu transacción fue validada con protocolo de seguridad SSL 256-Bit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                    // Banner de voucher enviado al correo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read, color: AppColors.success, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Voucher de compra enviado a:',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tarjeta con resumen de orden
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.mistLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _row('Número de Orden', '#${order.id}'),
                          const Divider(height: 14, color: AppColors.border),
                          _row('Total Pagado', formatCop(order.total), bold: true),
                          const Divider(height: 14, color: AppColors.border),
                          _row('Método de Pago', order.paymentLabel),
                          const Divider(height: 14, color: AppColors.border),
                          _row('Dirección de Entrega', order.address),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Botón para ver el voucher digital
                    if (activeVoucher != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => VoucherDialog.show(context, activeVoucher),
                          icon: const Icon(Icons.receipt_long, size: 18),
                          label: const Text('Ver Voucher / Boucher Digital'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => HomeScreen(app: app)),
                            (route) => false,
                          );
                          navigator.push(
                            MaterialPageRoute(builder: (_) => OrdersScreen(app: app)),
                          );
                        },
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Ir a "Mis Pedidos"'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => HomeScreen(app: app)),
                          (route) => false,
                        );
                      },
                      child: const Text('Volver al Catálogo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mist)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              fontSize: bold ? 13.5 : 12,
              color: bold ? AppColors.accent : AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
