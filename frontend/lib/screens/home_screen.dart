import 'package:flutter/material.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'chat_bot_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final CartState cartState;
  final ProductRepository? repository;

  const HomeScreen({
    super.key,
    required this.cartState,
    this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProductRepository _repository;
  ProductCategory _selected = ProductCategory.todos;
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? defaultProductRepository;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final results = await _repository.getProducts(category: _selected);
    if (mounted) {
      setState(() {
        _products = results;
        _isLoading = false;
      });
    }
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CartScreen(cartState: widget.cartState)),
    );
  }

  void _openBot() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChatBotScreen()),
    );
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
        title: const Text('Catálogo Electro'),
        actions: [
          IconButton(
            tooltip: 'Asistente virtual',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: _openBot,
          ),
          AnimatedBuilder(
            animation: widget.cartState,
            builder: (context, _) {
              final count = widget.cartState.totalItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Carrito de compras',
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: _openCart,
                  ),
                  if (count > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$count',
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
              );
            },
          ),
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
                    onSelected: (_) {
                      setState(() => _selected = cat);
                      _loadProducts();
                    },
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _products.isEmpty
                        ? const Center(
                            child: Text('No hay productos disponibles en esta categoría'),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _products.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                            itemBuilder: (context, index) {
                              final product = _products[index];
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
          ),
        ],
      ),
    );
  }
}
