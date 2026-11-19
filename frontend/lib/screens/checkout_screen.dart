import 'package:flutter/material.dart';

import '../services/secure_sales_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'confirmation_screen.dart';

enum PaymentMethod { nequi, tarjeta, contraentrega }

extension PaymentMethodInfo on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.nequi:
        return 'Nequi';
      case PaymentMethod.tarjeta:
        return 'Tarjeta débito / crédito';
      case PaymentMethod.contraentrega:
        return 'Pago contraentrega (Efecty)';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.nequi:
        return 'Transferencia rápida con notificación al celular';
      case PaymentMethod.tarjeta:
        return 'Visa, Mastercard o American Express';
      case PaymentMethod.contraentrega:
        return 'Paga en efectivo al recibir tu pedido';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.nequi:
        return Icons.phone_android;
      case PaymentMethod.tarjeta:
        return Icons.credit_card;
      case PaymentMethod.contraentrega:
        return Icons.local_shipping_outlined;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.nequi:
        return const Color(0xFF8B5CF6);
      case PaymentMethod.tarjeta:
        return AppColors.accent;
      case PaymentMethod.contraentrega:
        return const Color(0xFF059669);
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  final AppState app;
  const CheckoutScreen({super.key, required this.app});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selected = PaymentMethod.nequi;
  final TextEditingController _addressController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showMessage('Por favor escribe la dirección de entrega.');
      return;
    }

    if (!widget.app.isLoggedIn) {
      _showMessage('Debes iniciar sesión con tu cuenta para procesar una compra protegida.');
      return;
    }

    setState(() => _processing = true);

    // Si hay token JWT, sincronizar la orden de forma protegida con el backend
    if (widget.app.hasToken) {
      try {
        await widget.app.apiClient.post('/orders', body: {
          'customerName': widget.app.currentUser?.name ?? 'Cliente',
          'customerEmail': widget.app.currentUser?.email ?? 'cliente@correo.com',
          'shippingAddress': address,
          'paymentMethod': _selected.name,
          'items': widget.app.cart.items
              .map((e) => {'productId': e.product.id, 'quantity': e.qty})
              .toList(),
        });
      } catch (e) {
        debugPrint('Aviso: Orden procesada con voucher seguro local ($e)');
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final order = widget.app.placeOrder(
      paymentLabel: _selected.label,
      address: address,
    );
    if (order == null) {
      setState(() => _processing = false);
      _showMessage('Algún producto ya no tiene stock suficiente. Revisa tu carrito.');
      return;
    }

    final userEmail = widget.app.currentUser?.email ?? 'cliente.digital@correo.com';
    final voucher = await SecureSalesService.instance.processSecureSale(
      order: order,
      customerEmail: userEmail,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          app: widget.app,
          order: order,
          voucher: voucher,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.app.cart;

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dirección de Entrega
            const Text(
              'Dirección de Entrega',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Ej: Calle 25 # 10-20, Barrio Victoria, Tuluá',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.accent),
                suffixIcon: IconButton(
                  tooltip: 'Usar dirección sugerida',
                  icon: const Icon(Icons.auto_fix_high, size: 20, color: AppColors.accent),
                  onPressed: () {
                    setState(() {
                      _addressController.text = 'Calle 25 # 10-20, Tuluá (Valle)';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                setState(() {
                  _addressController.text = 'Calle 25 # 10-20, Tuluá (Valle)';
                });
              },
              child: const Text(
                '💡 Clic para autocompletar: Calle 25 # 10-20, Tuluá (Valle)',
                style: TextStyle(fontSize: 11.5, color: AppColors.mist),
              ),
            ),

            const SizedBox(height: 24),

            // Método de Pago
            const Text(
              'Método de Pago',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),

            ...PaymentMethod.values.map((method) {
              final active = _selected == method;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? method.color : AppColors.border,
                    width: active ? 1.8 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selected = method),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: method.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(method.icon, color: method.color, size: 22),
                  ),
                  title: Text(
                    method.label,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.ink,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    method.subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.mist),
                  ),
                  trailing: Radio<PaymentMethod>(
                    value: method,
                    // ignore: deprecated_member_use
                    groupValue: _selected,
                    // ignore: deprecated_member_use
                    onChanged: (val) => setState(() => _selected = val!),
                    activeColor: method.color,
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Color(0xFFD97706)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Modo prototipo de demostración: simula la transacción de la pasarela sin cobro bancario real.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Resumen de la Orden
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Pedido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal productos', style: TextStyle(color: AppColors.mist)),
                      Text(formatCop(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Envío estándar', style: TextStyle(color: AppColors.mist)),
                      Text(formatCop(cart.shipping), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a confirmar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.ink),
                      ),
                      Text(
                        formatCop(cart.total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _processing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text('Confirmar Pedido (${formatCop(cart.total)})'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
