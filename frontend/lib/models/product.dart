import 'package:flutter/material.dart';

/// Categorías del catálogo. Se modela como enum en vez de String suelto
/// para evitar errores de tipeo al filtrar (detectable en revisión de PR).
enum ProductCategory { todos, cables, proteccion, iluminacion, herramientas }

extension ProductCategoryInfo on ProductCategory {
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

  /// Color de fondo suave de la categoría (línea gráfica del proyecto).
  Color get tint {
    switch (this) {
      case ProductCategory.todos:
        return const Color(0xFFF1F5F9);
      case ProductCategory.cables:
        return const Color(0xFFE0F2FE);
      case ProductCategory.proteccion:
        return const Color(0xFFFEF3C7);
      case ProductCategory.iluminacion:
        return const Color(0xFFFEF9C3);
      case ProductCategory.herramientas:
        return const Color(0xFFDCFCE7);
    }
  }

  Color get iconColor {
    switch (this) {
      case ProductCategory.todos:
        return const Color(0xFF475569);
      case ProductCategory.cables:
        return const Color(0xFF0284C7);
      case ProductCategory.proteccion:
        return const Color(0xFFD97706);
      case ProductCategory.iluminacion:
        return const Color(0xFFCA8A04);
      case ProductCategory.herramientas:
        return const Color(0xFF16A34A);
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.todos:
        return Icons.category_outlined;
      case ProductCategory.cables:
        return Icons.cable;
      case ProductCategory.proteccion:
        return Icons.bolt;
      case ProductCategory.iluminacion:
        return Icons.lightbulb_outline;
      case ProductCategory.herramientas:
        return Icons.build_outlined;
    }
  }
}

/// Estado del stock de un producto. Siempre se comunica con texto,
/// no solo con color (criterio de accesibilidad de la línea gráfica).
enum StockStatus { disponible, pocas, agotado }

class Product {
  final int id;
  final ProductCategory category;
  final String name;
  final String sku;
  int price; // COP, sin decimales
  int stock; // unidades disponibles
  final String shortDescription;
  final String longDescription;
  final Map<String, String> specs;
  final List<String> applications;
  final List<String>? includes;
  final List<String>? standards;
  final String? brand;
  final String? warranty;
  final String? imageAsset;
  final String? imageGroup;
  final String? imageCredit;
  final double rating;
  final int reviewsCount;
  final String? featuredTag;

  Product({
    required this.id,
    required this.category,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.shortDescription = '',
    this.longDescription = '',
    this.specs = const {},
    this.applications = const [],
    this.includes,
    this.standards,
    this.brand,
    this.warranty,
    this.imageAsset,
    this.imageGroup,
    this.imageCredit,
    this.rating = 4.8,
    this.reviewsCount = 18,
    this.featuredTag,
  });

  Color get color => category.tint;
  IconData get icon => category.icon;

  /// Resumen plano de especificaciones para compatibilidad con vistas textuales y búsquedas.
  String get specsText => specs.entries.map((e) => '${e.key}: ${e.value}').join(' · ');

  String get resolvedImageAsset {
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return imageAsset!;
    }
    return 'assets/images/products/${sku.toLowerCase()}.jpg';
  }

  StockStatus get stockStatus {
    if (stock <= 0) return StockStatus.agotado;
    if (stock <= 5) return StockStatus.pocas;
    return StockStatus.disponible;
  }

  Product copyWith({
    int? id,
    ProductCategory? category,
    String? name,
    String? sku,
    int? price,
    int? stock,
    String? shortDescription,
    String? longDescription,
    Map<String, String>? specs,
    List<String>? applications,
    List<String>? includes,
    List<String>? standards,
    String? brand,
    String? warranty,
    String? imageAsset,
    String? imageGroup,
    String? imageCredit,
    double? rating,
    int? reviewsCount,
    String? featuredTag,
  }) {
    return Product(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      specs: specs ?? this.specs,
      applications: applications ?? this.applications,
      includes: includes ?? this.includes,
      standards: standards ?? this.standards,
      brand: brand ?? this.brand,
      warranty: warranty ?? this.warranty,
      imageAsset: imageAsset ?? this.imageAsset,
      imageGroup: imageGroup ?? this.imageGroup,
      imageCredit: imageCredit ?? this.imageCredit,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      featuredTag: featuredTag ?? this.featuredTag,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sku == other.sku;

  @override
  int get hashCode => id.hashCode ^ sku.hashCode;

  @override
  String toString() =>
      'Product(id: $id, sku: $sku, name: $name, price: $price, stock: $stock)';
}
