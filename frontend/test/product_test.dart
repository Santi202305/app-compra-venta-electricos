import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Creación correcta de producto de materiales eléctricos', () {
      const product = Product(
        id: 101,
        name: 'Cable Cobre THHN 12 AWG',
        sku: 'CBL-THN-12',
        description: 'Cable eléctrico de cobre para instalaciones residenciales e industriales.',
        price: 4500,
        category: ProductCategory.cables,
        imageUrl: 'https://via.placeholder.com/150',
      );

      expect(product.id, 101);
      expect(product.name, 'Cable Cobre THHN 12 AWG');
      expect(product.sku, 'CBL-THN-12');
      expect(product.price, 4500);
      expect(product.category, ProductCategory.cables);
      expect(product.category.label, 'Cables');
      expect(product.description, contains('Cable eléctrico de cobre'));
      expect(product.imageUrl, 'https://via.placeholder.com/150');
      expect(product.retieCompliant, isTrue);
    });

    test('Serialización y deserialización desde JSON (API)', () {
      final json = {
        'id': 202,
        'category': 'proteccion',
        'name': 'Breaker Riel DIN 32A',
        'sku': 'BRK-DIN-32A',
        'price': 42000,
        'stock': 15,
        'description': 'Interruptor termomagnético RETIE',
        'imageUrl': 'https://example.com/breaker.jpg',
        'retieCompliant': true,
        'colorHex': '#F0EBFF',
        'iconName': 'bolt',
      };

      final product = Product.fromJson(json);

      expect(product.id, 202);
      expect(product.category, ProductCategory.proteccion);
      expect(product.name, 'Breaker Riel DIN 32A');
      expect(product.sku, 'BRK-DIN-32A');
      expect(product.price, 42000);
      expect(product.stock, 15);
      expect(product.retieCompliant, isTrue);

      final outputJson = product.toJson();
      expect(outputJson['id'], 202);
      expect(outputJson['category'], 'proteccion');
      expect(outputJson['price'], 42000);
    });

    test('Mapeo de ProductCategoryLabel.fromString para categorías diversas', () {
      expect(ProductCategoryLabel.fromString('Cables y Conductores'), ProductCategory.cables);
      expect(ProductCategoryLabel.fromString('Protección y Tableros'), ProductCategory.proteccion);
      expect(ProductCategoryLabel.fromString('Iluminación LED'), ProductCategory.iluminacion);
      expect(ProductCategoryLabel.fromString('Herramientas'), ProductCategory.herramientas);
      expect(ProductCategoryLabel.fromString(null), ProductCategory.todos);
    });
  });
}
