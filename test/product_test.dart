import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Creación correcta de producto de materiales eléctricos', () {
      final product = Product(
        id: 'p101',
        name: 'Cable Cobre THHN 12 AWG',
        description: 'Cable eléctrico de cobre para instalaciones residenciales e industriales.',
        price: 4500.0,
        category: 'Cables y Conductores',
        imageUrl: 'https://via.placeholder.com/150',
      );

      expect(product.id, 'p101');
      expect(product.name, 'Cable Cobre THHN 12 AWG');
      expect(product.price, 4500.0);
      expect(product.category, 'Cables y Conductores');
    });
  });
}
