import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/secure_sales_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'voucher_dialog.dart';

/// Tarjeta moderna de pedido para historial de clientes y panel de administración.
class OrderCard extends StatelessWidget {
  final Order order;
  final Widget? trailing;
  final bool showUser;

  const OrderCard({
    super.key,
    required this.order,
    this.trailing,
    this.showUser = false,
  });

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pendiente:
        return AppColors.warm;
      case OrderStatus.enCamino:
        return const Color(0xFF0284C7);
      case OrderStatus.entregado:
        return AppColors.success;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.pendiente:
        return Icons.schedule;
      case OrderStatus.enCamino:
        return Icons.local_shipping;
      case OrderStatus.entregado:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Orden #${order.id}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 13, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(
                      order.status.label,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 3),
          Text(
            formatDate(order.date),
            style: const TextStyle(fontSize: 11.5, color: AppColors.mist),
          ),
          if (showUser) ...[
            const SizedBox(height: 2),
            Text(
              'Cliente: ${order.userEmail}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          ...order.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${line.qty} × ${line.productName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.ink),
                    ),
                  ),
                  Text(
                    formatCop(line.total),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total (con envío)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              Text(
                formatCop(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.payment, size: 14, color: AppColors.mist),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${order.paymentLabel} · ${order.address}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.mist),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                var v = SecureSalesService.instance.getVoucherForOrder(order.id);
                v ??= await SecureSalesService.instance.processSecureSale(
                  order: order,
                  customerEmail: order.userEmail,
                );
                if (context.mounted) {
                  VoucherDialog.show(context, v);
                }
              },
              icon: const Icon(Icons.receipt_long, size: 14),
              label: const Text('Ver Voucher / Boucher Digital', style: TextStyle(fontSize: 11.5)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
