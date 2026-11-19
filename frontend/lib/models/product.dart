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

  static ProductCategory fromString(String? value) {
    if (value == null) return ProductCategory.todos;
    final lower = value.toLowerCase().trim();
    if (lower.contains('cable')) return ProductCategory.cables;
    if (lower.contains('protec')) return ProductCategory.proteccion;
    if (lower.contains('ilumin') || lower.contains('led')) return ProductCategory.iluminacion;
    if (lower.contains('herram')) return ProductCategory.herramientas;
    for (final cat in ProductCategory.values) {
      if (cat.name.toLowerCase() == lower) return cat;
    }
    return ProductCategory.todos;
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
  final String description;
  final String? imageUrl;
  final bool retieCompliant;

  const Product({
    required this.id,
    required this.category,
    required this.name,
    this.sku = '',
    required this.price,
    this.color = const Color(0xFFE3F0FF),
    this.icon = Icons.electrical_services,
    this.stock = 46,
    this.description = '',
    this.imageUrl,
    this.retieCompliant = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      category: ProductCategoryLabel.fromString(json['category']?.toString()),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: json['price'] is int
          ? json['price'] as int
          : (json['price'] as num?)?.round() ?? 0,
      stock: json['stock'] is int
          ? json['stock'] as int
          : (json['stock'] as num?)?.round() ?? 46,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      retieCompliant: json['retieCompliant'] == true || json['retieCompliant'] == null,
      color: _colorFromHex(json['colorHex']?.toString()),
      icon: _iconFromName(json['iconName']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'sku': sku,
      'price': price,
      'stock': stock,
      'description': description,
      'imageUrl': imageUrl,
      'retieCompliant': retieCompliant,
    };
  }

  static Color _colorFromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFFE3F0FF);
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFFE3F0FF);
    }
  }

  static IconData _iconFromName(String? iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'cable':
        return Icons.cable;
      case 'lightbulb_outline':
        return Icons.lightbulb_outline;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.electrical_services;
    }
  }
}
