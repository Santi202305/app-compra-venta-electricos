import '../data/products.dart';
import '../models/product.dart';

/// Contrato abstracto para el acceso y consulta del catálogo de productos.
/// Permite intercambiar la fuente de datos local por una API REST, SQLite o Firebase
/// sin alterar las capas superiores de la aplicación (AppState / UI).
abstract class ProductRepository {
  /// Obtiene la lista completa de productos disponibles.
  Future<List<Product>> getAll();

  /// Busca un producto por su identificador numérico único.
  Future<Product?> getById(int id);

  /// Busca un producto por su código SKU.
  Future<Product?> getBySku(String sku);

  /// Filtra productos pertenecientes a una categoría específica.
  Future<List<Product>> getByCategory(ProductCategory category);

  /// Búsqueda textual sobre nombre, SKU, especificaciones y aplicaciones.
  Future<List<Product>> search(String query);
}

/// Implementación local del repositorio que opera sobre el catálogo tipado en memoria.
class LocalProductRepository implements ProductRepository {
  final List<Product> Function() _catalogProvider;
  List<Product>? _cachedProducts;

  LocalProductRepository({
    List<Product> Function() catalogProvider = buildSampleProducts,
  }) : _catalogProvider = catalogProvider;

  List<Product> _getOrLoad() {
    return _cachedProducts ??= _catalogProvider();
  }

  @override
  Future<List<Product>> getAll() async {
    // Simula una operación asíncrona limpia
    return List<Product>.unmodifiable(_getOrLoad());
  }

  @override
  Future<Product?> getById(int id) async {
    final list = _getOrLoad();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Product?> getBySku(String sku) async {
    final list = _getOrLoad();
    final normalizedSku = sku.trim().toUpperCase();
    try {
      return list.firstWhere(
        (p) => p.sku.trim().toUpperCase() == normalizedSku,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> getByCategory(ProductCategory category) async {
    final list = _getOrLoad();
    return List<Product>.unmodifiable(
      list.where((p) => p.category == category),
    );
  }

  @override
  Future<List<Product>> search(String query) async {
    final list = _getOrLoad();
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return List<Product>.unmodifiable(list);

    return List<Product>.unmodifiable(
      list.where((p) {
        final inName = p.name.toLowerCase().contains(trimmed);
        final inSku = p.sku.toLowerCase().contains(trimmed);
        final inShortDesc = p.shortDescription.toLowerCase().contains(trimmed);
        final inSpecs = p.specsText.toLowerCase().contains(trimmed);
        final inCategory = p.category.label.toLowerCase().contains(trimmed);
        final inBrand = p.brand?.toLowerCase().contains(trimmed) ?? false;
        final inApps = p.applications.any((app) => app.toLowerCase().contains(trimmed));

        return inName || inSku || inShortDesc || inSpecs || inCategory || inBrand || inApps;
      }),
    );
  }
}
