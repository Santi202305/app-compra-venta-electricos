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

  /// Agrega unidades al carrito. Devuelve false (y no cambia nada) si
  /// no hay stock suficiente para la cantidad pedida.
  bool addProduct(Product product, int qty) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    final current = index == -1 ? 0 : _items[index].qty;
    if (qty <= 0 || product.stock <= 0 || current + qty > product.stock) {
      return false;
    }
    if (index == -1) {
      _items.add(CartEntry(product, qty));
    } else {
      _items[index].qty += qty;
    }
    notifyListeners();
    return true;
  }

  /// Suma o resta unidades de un producto ya agregado. Si la cantidad
  /// llega a cero se quita del carrito; no permite superar el stock.
  void changeQty(int productId, int delta) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index == -1) return;
    final entry = _items[index];
    final next = entry.qty + delta;
    if (next <= 0) {
      _items.removeAt(index);
    } else if (next <= entry.product.stock) {
      entry.qty = next;
    } else {
      return;
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
