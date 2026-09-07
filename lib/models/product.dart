import 'package:flutter/material.dart';

/// Categorías del catálogo. Se modela como enum en vez de String suelto
/// para evitar errores de tipeo al filtrar (detectable en revisión de PR).
enum ProductCategory { todos, cables, proteccion, iluminacion, herramientas }

extension ProductCategoryLabel on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.todos:
        return 'Todos';
      case ProductCategory.cables:
        return 'Cables';
      case ProductCategory.proteccion:
        return 'Protección';
      case ProductCategory.iluminacion:
        return 'Iluminación';
      case ProductCategory.herramientas:
        return 'Herramientas';
    }
  }
}

class Product {
  final int id;
  final ProductCategory category;
  final String name;
  final String sku;
  final int price; // COP, sin decimales
  final Color color;
  final IconData icon;
  final int stock;

  const Product({
    required this.id,
    required this.category,
    required this.name,
    required this.sku,
    required this.price,
    required this.color,
    required this.icon,
    this.stock = 46,
  });
}
