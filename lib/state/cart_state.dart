import 'package:flutter/foundation.dart';

import '../data/products.dart';
import '../models/product.dart';

class CartEntry {
  final Product product;
  int qty;
  CartEntry(this.product, this.qty);

  int get lineTotal => product.price * qty;
}

/// Estado del carrito de compras, separado de la capa de presentación
/// (pantallas) siguiendo la separación de capas acordada en la
/// clasificación técnica del proyecto.
class CartState extends ChangeNotifier {
  final List<CartEntry> _items = [];

  List<CartEntry> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, e) => sum + e.qty);

  int get subtotal => _items.fold(0, (sum, e) => sum + e.lineTotal);

  int get shipping => _items.isEmpty ? 0 : kShippingCost;

  int get total => subtotal + shipping;

  void addProduct(Product product, int qty) {
    final existing = _items.where((e) => e.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      _items.add(CartEntry(product, qty));
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
