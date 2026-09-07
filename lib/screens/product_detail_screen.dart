import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final CartState cartState;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cartState,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  void _changeQty(int delta) {
    setState(() {
      _qty = (_qty + delta).clamp(1, widget.product.stock);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final remainingStock = product.stock - _qty;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(product.icon, size: 64, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('SKU: ${product.sku}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Chip(
              backgroundColor: AppColors.success.withOpacity(.12),
              label: Text(
                '✓ $remainingStock unidades disponibles',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeQty(-1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_qty', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      onPressed: () => _changeQty(1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                widget.cartState.addProduct(product, _qty);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} (x$_qty) agregado'),
                  ),
                );
              },
              child: const Text('Agregar al carrito'),
            ),
          ],
        ),
      ),
    );
  }
}
