import 'package:flutter/material.dart';

import '../services/secure_sales_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Modal interactivo que muestra el Voucher / Comprobante de Compra Encriptado.
class VoucherDialog extends StatefulWidget {
  final SaleVoucher voucher;

  const VoucherDialog({super.key, required this.voucher});

  static Future<void> show(BuildContext context, SaleVoucher voucher) {
    return showDialog<void>(
      context: context,
      builder: (_) => VoucherDialog(voucher: voucher),
    );
  }

  @override
  State<VoucherDialog> createState() => _VoucherDialogState();
}

class _VoucherDialogState extends State<VoucherDialog> {
  bool _resending = false;

  void _resendEmail() async {
    setState(() => _resending = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher reenviado con éxito a ${widget.voucher.customerEmail}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.voucher;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge de seguridad encriptada
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: AppColors.success, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'TRANSACCIÓN ENCRIPTADA SSL 256-BIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cabecera Empresa
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ELECTRO INDUSTRIAL',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'NIT: 901.482.193-4 · Certificación RETIE',
                          style: TextStyle(fontSize: 11, color: AppColors.mist),
                        ),
                        Text(
                          'Facturación Electrónica DIAN',
                          style: TextStyle(fontSize: 10.5, color: AppColors.mist),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'ORDEN #${v.orderId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.border),
              const SizedBox(height: 10),

              // Datos del cliente y despacho de correo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voucher enviado por correo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF166534),
                            ),
                          ),
                          Text(
                            v.customerEmail,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _infoItem('Código de Autorización', v.authorizationCode),
              _infoItem('Fecha y Hora', formatDate(v.timestamp)),
              _infoItem('Método de Pago', v.paymentMethod),
              _infoItem('Dirección de Envío', v.customerAddress),

              const SizedBox(height: 10),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),

              // Lista de productos
              const Text(
                'Detalle de Materiales',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              ...v.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${line.qty}x ${line.productName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.ink),
                        ),
                      ),
                      Text(
                        formatCop(line.total),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),

              // Desglose Financiero
              _summaryRow('Subtotal Base', formatCop(v.subtotal)),
              _summaryRow('IVA (19% Discriminado)', formatCop(v.iva)),
              _summaryRow('Envío Asegurado', formatCop(v.shipping)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL COBRADO',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.ink),
                  ),
                  Text(
                    formatCop(v.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Firma Criptográfica
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mistLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firma Digital Criptográfica (SHA-256):',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.mist),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      v.securitySignature,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resending ? null : _resendEmail,
                      icon: _resending
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined, size: 16),
                      label: const Text('Reenviar Correo', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cerrar Voucher', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.mist)),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.mist)),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}
