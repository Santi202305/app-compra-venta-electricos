import 'package:flutter/material.dart';

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
}

class CheckoutScreen extends StatefulWidget {
  final CartState cartState;
  const CheckoutScreen({super.key, required this.cartState});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selected = PaymentMethod.nequi;

  void _confirmOrder() {
    // NOTA: aquí es donde, en la versión real, se llamaría al backend
    // (Spring Boot) para crear el pedido y a la pasarela de pagos
    // (Wompi/PayU/ePayco) para procesar el cobro con Nequi o Efecty.
    widget.cartState.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(cartState: widget.cartState),
      ),
    );
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
                groupValue: _selected,
                onChanged: (value) => setState(() => _selected = value!),
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
              onPressed: _confirmOrder,
              child: const Text('Confirmar pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
