import '../api/api_client.dart';
import '../data/products.dart';
import '../models/product.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? defaultApiClient;

  Future<List<Product>> getProducts({ProductCategory? category, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category != ProductCategory.todos) {
        queryParams['category'] = category.name;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get('/products', queryParams: queryParams.isNotEmpty ? queryParams : null);

      if (response is Map<String, dynamic> && response['data'] is List) {
        final list = response['data'] as List<dynamic>;
        return list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      }

      return _localFallback(category: category, search: search);
    } catch (_) {
      // Fallback transparente al catálogo local en caso de desconexión o error de red
      return _localFallback(category: category, search: search);
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      final response = await _apiClient.get('/products/$id');
      if (response is Map<String, dynamic> && response['data'] is Map<String, dynamic>) {
        return Product.fromJson(response['data'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback al catálogo local
    }

    try {
      return kProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> _localFallback({ProductCategory? category, String? search}) {
    var result = List<Product>.from(kProducts);
    if (category != null && category != ProductCategory.todos) {
      result = result.where((p) => p.category == category).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }
}

final defaultProductRepository = ProductRepository();
