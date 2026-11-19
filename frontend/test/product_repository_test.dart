import 'package:flutter_test/flutter_test.dart';

import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/repositories/product_repository.dart';
import 'package:app_compra_venta_electricos/state/app_state.dart';

class _FailingProductRepository implements ProductRepository {
  bool shouldFail = true;

  @override
  Future<List<Product>> getAll() async {
    if (shouldFail) {
      throw Exception('Fallo de conexión con el servidor de inventario');
    }
    return [
      Product(
        id: 999,
        category: ProductCategory.proteccion,
        name: 'Breaker de Prueba',
        sku: 'TEST-BRK-01',
        price: 25000,
        stock: 10,
      ),
    ];
  }

  @override
  Future<Product?> getById(int id) async => null;

  @override
  Future<Product?> getBySku(String sku) async => null;

  @override
  Future<List<Product>> getByCategory(ProductCategory category) async => [];

  @override
  Future<List<Product>> search(String query) async => [];
}

void main() {
  group('Fase 6 - Arquitectura Limpia y Robustez (ProductRepository y AppState)', () {
    late LocalProductRepository repository;

    setUp(() {
      repository = LocalProductRepository();
    });

    test('1. LocalProductRepository.getAll() entrega el catálogo completo de 35 productos', () async {
      final products = await repository.getAll();
      expect(products.length, 35);
      expect(products.every((p) => p.sku.isNotEmpty), isTrue);
    });

    test('2. LocalProductRepository.getById() busca por ID y maneja IDs inexistentes', () async {
      final p1 = await repository.getById(1);
      expect(p1, isNotNull);
      expect(p1!.id, 1);
      expect(p1.sku, 'BRK-220-20A');

      final notFound = await repository.getById(99999);
      expect(notFound, isNull);
    });

    test('3. LocalProductRepository.getBySku() busca por SKU sin distinguir mayúsculas', () async {
      final p = await repository.getBySku('cbl-thn-12');
      expect(p, isNotNull);
      expect(p!.sku, 'CBL-THN-12');
      expect(p.name, contains('THHN #12'));

      final notFound = await repository.getBySku('SKU-INEXISTENTE');
      expect(notFound, isNull);
    });

    test('4. LocalProductRepository.getByCategory() filtra exactamente por categoría', () async {
      final cables = await repository.getByCategory(ProductCategory.cables);
      expect(cables, isNotEmpty);
      expect(cables.every((p) => p.category == ProductCategory.cables), isTrue);

      final tools = await repository.getByCategory(ProductCategory.herramientas);
      expect(tools, isNotEmpty);
      expect(tools.every((p) => p.category == ProductCategory.herramientas), isTrue);
    });

    test('5. LocalProductRepository.search() busca por nombre, SKU, marca y especificaciones', () async {
      // Por nombre / tipo
      final breakers = await repository.search('breaker');
      expect(breakers, isNotEmpty);

      // Por SKU exacto o parcial
      final bySku = await repository.search('THN-10');
      expect(bySku, isNotEmpty);
      expect(bySku.first.sku, 'CBL-THN-10');

      // Búsqueda vacía retorna catálogo completo
      final all = await repository.search('   ');
      expect(all.length, 35);
    });

    test('6. AppState inyecta ProductRepository por defecto y carga productos', () {
      final app = AppState();
      expect(app.productRepository, isA<ProductRepository>());
      expect(app.products.length, 35);
      expect(app.isLoadingProducts, isFalse);
      expect(app.productsError, isNull);
    });

    test('7. AppState.loadProducts() actualiza productos y gestiona ciclo de carga asíncrono', () async {
      final app = AppState(productRepository: repository);

      final future = app.loadProducts();
      // Durante la carga
      expect(app.isLoadingProducts, isTrue);

      await future;

      // Al culminar la carga con éxito
      expect(app.isLoadingProducts, isFalse);
      expect(app.productsError, isNull);
      expect(app.products.length, 35);
    });

    test('8. AppState maneja errores de red en repositorio con pantalla de reintento limpia', () async {
      final failingRepo = _FailingProductRepository();
      final app = AppState(productRepository: failingRepo);

      // Primer intento: falla y captura error
      await app.loadProducts();
      expect(app.isLoadingProducts, isFalse);
      expect(app.productsError, isNotNull);
      expect(app.productsError, contains('Error al cargar el inventario'));

      // Simula recuperación del servicio y reintento exitoso
      failingRepo.shouldFail = false;
      await app.loadProducts();
      expect(app.isLoadingProducts, isFalse);
      expect(app.productsError, isNull);
      expect(app.products.length, 1);
      expect(app.products.first.sku, 'TEST-BRK-01');
    });

    test('9. Product inmutabilidad, sobreescritura de operator ==, hashCode y toString', () {
      final p1 = Product(
        id: 10,
        category: ProductCategory.proteccion,
        name: 'Breaker A',
        sku: 'BRK-A',
        price: 20000,
        stock: 5,
      );
      final p2 = Product(
        id: 10,
        category: ProductCategory.proteccion,
        name: 'Breaker A Modificado',
        sku: 'BRK-A',
        price: 30000,
        stock: 8,
      );
      final p3 = Product(
        id: 11,
        category: ProductCategory.proteccion,
        name: 'Breaker B',
        sku: 'BRK-B',
        price: 20000,
        stock: 5,
      );

      // Igualdad basada en id y sku
      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));

      // copyWith genera nueva instancia
      final pCopied = p1.copyWith(price: 22000);
      expect(pCopied.id, 10);
      expect(pCopied.price, 22000);

      // toString descriptivo
      expect(p1.toString(), contains('BRK-A'));
      expect(p1.toString(), contains('id: 10'));
    });
  });
}
