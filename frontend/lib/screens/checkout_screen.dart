import 'package:flutter/material.dart';

import '../repositories/order_repository.dart';
import '../state/cart_state.dart';
import 'confirmation_screen.dart';

enum PaymentMethod { nequi, tarjeta, contraentrega }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.nequi:
        return 'Nequi';
      case PaymentMethod.tarjeta:
        return 'Tarjeta débito/crédito';
      case PaymentMethod.contraentrega:
        return 'Pago contraentrega (Efecty)';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.nequi:
        return 'nequi';
      case PaymentMethod.tarjeta:
        return 'tarjeta';
      case PaymentMethod.contraentrega:
        return 'efecty';
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  final CartState cartState;
  final OrderRepository? repository;

  const CheckoutScreen({
    super.key,
    required this.cartState,
    this.repository,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selected = PaymentMethod.nequi;
  bool _isSubmitting = false;

  Future<void> _confirmOrder() async {
    setState(() => _isSubmitting = true);

    final repository = widget.repository ?? defaultOrderRepository;
    await repository.submitOrder(
      cartState: widget.cartState,
      customerName: 'Electricista Registrado',
      customerEmail: 'cliente@electroindustrial.com.co',
      shippingAddress: 'Dirección del proyecto eléctrico',
      paymentMethod: _selected.apiValue,
    );

    widget.cartState.clear();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConfirmationScreen(cartState: widget.cartState),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Método de pago',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...PaymentMethod.values.map(
              (method) => RadioListTile<PaymentMethod>(
                contentPadding: EdgeInsets.zero,
                value: method,
                // ignore: deprecated_member_use
                groupValue: _selected,
                // ignore: deprecated_member_use
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _selected = value!),
                title: Text(method.label),
              ),
            ),
            const SizedBox(height: 20),
            Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Subtotal: \$${widget.cartState.subtotal}'),
            Text('Envío: \$${widget.cartState.shipping}'),
            Text(
              'Total: \$${widget.cartState.total}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _confirmOrder,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirmar pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
