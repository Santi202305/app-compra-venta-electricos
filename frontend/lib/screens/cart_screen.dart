import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/breakpoints.dart';
import '../utils/format.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final AppState app;
  const CartScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final cart = app.cart;
    final isExpanded = context.isExpanded;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito de Compras'),
        actions: [
          AnimatedBuilder(
            animation: cart,
            builder: (context, _) => cart.items.isNotEmpty
                ? TextButton(
                    onPressed: () => cart.clear(),
                    child: const Text('Vaciar', style: TextStyle(color: AppColors.danger)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 52,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Explora nuestro catálogo y agrega los materiales que necesitas para tu proyecto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.mist),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Volver al catálogo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final itemList = ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = cart.items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagen del producto
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          entry.product.resolvedImageAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            entry.product.icon,
                            color: entry.product.category.iconColor,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Detalles y controles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.product.sku} · ${formatCop(entry.product.price)} c/u',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.mist,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Selector de cantidad
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              _qtyButton(
                                icon: Icons.remove,
                                onTap: () => cart.changeQty(entry.product.id, entry.qty - 1),
                              ),
                              Text(
                                '${entry.qty}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.ink,
                                ),
                              ),
                              _qtyButton(
                                icon: Icons.add,
                                onTap: entry.qty < entry.product.stock
                                    ? () => cart.changeQty(entry.product.id, entry.qty + 1)
                                    : null,
                              ),
                              Text(
                                'Máx. ${entry.product.stock}',
                                style: const TextStyle(fontSize: 10, color: AppColors.mist),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Total de la línea y eliminar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.mist),
                          onPressed: () => cart.removeProduct(entry.product.id),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formatCop(entry.lineTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );

          final summaryCard = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: isExpanded ? BorderRadius.circular(8) : null,
              border: isExpanded
                  ? Border.all(color: AppColors.border)
                  : const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de la Cotización',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _summaryRow('Subtotal de materiales', cart.subtotal),
                  _summaryRow('Costo de envío garantizado', cart.shipping),
                  const SizedBox(height: 6),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 6),
                  _summaryRow('Total a pagar', cart.total, bold: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(app: app),
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: const Text('Continuar al Checkout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (isExpanded) {
            // Diseño escritorio a dos columnas
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Scrollbar(child: itemList),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 380,
                        child: summaryCard,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Diseño móvil / tablet vertical
          return Column(
            children: [
              Expanded(child: itemList),
              summaryCard,
            ],
          );
        },
      ),
    );
  }

  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? const Color(0xFFBFDBFE) : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled ? AppColors.accent : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, int value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                fontSize: bold ? 15 : 13,
                color: bold ? AppColors.ink : AppColors.mist,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCop(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              fontSize: bold ? 16 : 13.5,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
