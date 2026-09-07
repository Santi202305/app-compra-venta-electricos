import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'chat_bot_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final CartState cartState;
  const HomeScreen({super.key, required this.cartState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductCategory _selected = ProductCategory.todos;

  List<Product> get _filtered {
    if (_selected == ProductCategory.todos) return kProducts;
    return kProducts.where((p) => p.category == _selected).toList();
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CartScreen(cartState: widget.cartState)),
    );
  }

  void _openBot() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatBotScreen()),
    );
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          cartState: widget.cartState,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Asistente virtual',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: _openBot,
          ),
          AnimatedBuilder(
            animation: widget.cartState,
            builder: (context, _) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: _openCart,
                ),
                if (widget.cartState.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${widget.cartState.totalItems}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ProductCategory.values.map((cat) {
                final active = cat == _selected;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.label),
                    selected: active,
                    onSelected: (_) => setState(() => _selected = cat),
                    labelStyle: TextStyle(
                      color: active ? Colors.white : AppColors.ink,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = _filtered[index];
                return ProductCard(
                  product: product,
                  onTap: () => _openDetail(product),
                  onQuickAdd: () {
                    widget.cartState.addProduct(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} agregado al carrito'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
