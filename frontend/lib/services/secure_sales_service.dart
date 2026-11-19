import 'dart:convert';
import 'dart:math';

import '../models/order.dart';

/// Modelo del comprobante / voucher digital de compra.
class SaleVoucher {
  final int orderId;
  final String authorizationCode;
  final String encryptedTransactionToken;
  final String securitySignature;
  final DateTime timestamp;
  final String customerEmail;
  final String customerAddress;
  final String paymentMethod;
  final List<OrderLine> lines;
  final int subtotal;
  final int iva;
  final int shipping;
  final int total;
  final bool emailSent;
  final String emailRecipient;

  const SaleVoucher({
    required this.orderId,
    required this.authorizationCode,
    required this.encryptedTransactionToken,
    required this.securitySignature,
    required this.timestamp,
    required this.customerEmail,
    required this.customerAddress,
    required this.paymentMethod,
    required this.lines,
    required this.subtotal,
    required this.iva,
    required this.shipping,
    required this.total,
    required this.emailSent,
    required this.emailRecipient,
  });
}

/// Servicio de ventas con encriptación de seguridad y despacho de vouchers.
class SecureSalesService {
  SecureSalesService._();

  static final SecureSalesService instance = SecureSalesService._();

  final List<SaleVoucher> _voucherHistory = [];

  List<SaleVoucher> get voucherHistory => List.unmodifiable(_voucherHistory);

  /// Genera un token hash SHA-256 simulado para la transacción.
  String _generateSecurityHash(String input) {
    final bytes = utf8.encode(input);
    int h1 = 0x6a09e667;
    int h2 = 0xbb67ae85;
    int h3 = 0x3c6ef372;
    int h4 = 0xa54ff53a;

    for (int i = 0; i < bytes.length; i++) {
      h1 = (h1 ^ (bytes[i] * 31)) & 0xFFFFFFFF;
      h2 = (h2 ^ (bytes[i] * 37)) & 0xFFFFFFFF;
      h3 = (h3 ^ (bytes[i] * 41)) & 0xFFFFFFFF;
      h4 = (h4 ^ (bytes[i] * 43)) & 0xFFFFFFFF;
    }

    final p1 = h1.toRadixString(16).padLeft(8, '0');
    final p2 = h2.toRadixString(16).padLeft(8, '0');
    final p3 = h3.toRadixString(16).padLeft(8, '0');
    final p4 = h4.toRadixString(16).padLeft(8, '0');
    return '$p1$p2$p3$p4'.toUpperCase();
  }

  /// Procesa la venta con encriptación, genera el voucher y simula el envío por correo.
  Future<SaleVoucher> processSecureSale({
    required Order order,
    required String customerEmail,
  }) async {
    // 1. Simulación de handshake TLS y encriptación de payload de pago
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final randomAuth = 100000 + Random().nextInt(899999);
    final authCode = 'AUTH-SEC-$randomAuth';

    // Generar payload encriptado en Base64 con firma de seguridad
    final rawPayload = {
      'order_id': order.id,
      'amount': order.total,
      'client': customerEmail,
      'timestamp': DateTime.now().toIso8601String(),
      'gateway_protocol': 'SSL-AES-256-GCM',
    };
    final jsonStr = jsonEncode(rawPayload);
    final encryptedToken = base64Encode(utf8.encode(jsonStr));
    final signature = _generateSecurityHash('ORDER-${order.id}-$encryptedToken-$customerEmail');

    // Desglose tributario colombiano (19% IVA aproximado incluido o calculado)
    final ivaCalculado = (order.subtotal * 0.19 / 1.19).round();

    final voucher = SaleVoucher(
      orderId: order.id,
      authorizationCode: authCode,
      encryptedTransactionToken: encryptedToken,
      securitySignature: signature,
      timestamp: DateTime.now(),
      customerEmail: customerEmail,
      customerAddress: order.address,
      paymentMethod: order.paymentLabel,
      lines: order.lines,
      subtotal: order.subtotal - ivaCalculado,
      iva: ivaCalculado,
      shipping: order.shipping,
      total: order.total,
      emailSent: true,
      emailRecipient: customerEmail,
    );

    _voucherHistory.add(voucher);
    return voucher;
  }

  /// Busca el voucher asociado a una orden.
  SaleVoucher? getVoucherForOrder(int orderId) {
    return _voucherHistory.where((v) => v.orderId == orderId).firstOrNull;
  }
}
