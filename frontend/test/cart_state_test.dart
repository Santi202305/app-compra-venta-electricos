import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/state/cart_state.dart';

void main() {
  group('CartState Unit Tests', () {
    late CartState cartState;

    setUp(() {
      cartState = CartState();
    });

    test('Estado inicial del carrito es vacío con costo de envío \$0', () {
      expect(cartState.items.isEmpty, isTrue);
      expect(cartState.totalItems, 0);
      expect(cartState.subtotal, 0);
      expect(cartState.shipping, 0);
      expect(cartState.total, 0);
    });

    test('Agregar producto calcula correctamente subtotal, flete nacional (\$12.000) y total', () {
      const product1 = Product(
        id: 1,
        category: ProductCategory.proteccion,
        name: 'Breaker 20A',
        sku: 'BRK-20A',
        price: 38900,
      );

      cartState.addProduct(product1, 2);

      expect(cartState.items.length, 1);
      expect(cartState.totalItems, 2);
      expect(cartState.subtotal, 77800); // 38900 * 2
      expect(cartState.shipping, 12000); // Flete nacional
      expect(cartState.total, 89800); // 77800 + 12000
    });

    test('Agregar producto duplicado incrementa la cantidad acumulada sin duplicar item', () {
      const product1 = Product(
        id: 1,
        category: ProductCategory.proteccion,
        name: 'Breaker 20A',
        sku: 'BRK-20A',
        price: 38900,
      );

      cartState.addProduct(product1, 1);
      cartState.addProduct(product1, 3);

      expect(cartState.items.length, 1);
      expect(cartState.totalItems, 4);
      expect(cartState.items.first.qty, 4);
      expect(cartState.subtotal, 38900 * 4);
    });

    test('Remover producto por ID actualiza subtotal y flete', () {
      const p1 = Product(id: 1, category: ProductCategory.proteccion, name: 'P1', sku: 'S1', price: 10000);
      const p2 = Product(id: 2, category: ProductCategory.cables, name: 'P2', sku: 'S2', price: 20000);

      cartState.addProduct(p1, 1);
      cartState.addProduct(p2, 1);

      expect(cartState.items.length, 2);
      expect(cartState.subtotal, 30000);

      cartState.removeProduct(1);

      expect(cartState.items.length, 1);
      expect(cartState.items.first.product.id, 2);
      expect(cartState.subtotal, 20000);
    });

    test('clear() restablece todos los valores a cero', () {
      const p = Product(id: 1, category: ProductCategory.proteccion, name: 'P', sku: 'S', price: 15000);
      cartState.addProduct(p, 5);
      expect(cartState.totalItems, 5);

      cartState.clear();

      expect(cartState.items.isEmpty, isTrue);
      expect(cartState.totalItems, 0);
      expect(cartState.subtotal, 0);
      expect(cartState.shipping, 0);
      expect(cartState.total, 0);
    });

    test('notifyListeners() se dispara con cada cambio de estado', () {
      var listenerCalls = 0;
      cartState.addListener(() {
        listenerCalls++;
      });

      const p = Product(id: 1, category: ProductCategory.cables, name: 'P', sku: 'S', price: 5000);
      cartState.addProduct(p, 1); // +1
      cartState.addProduct(p, 2); // +1
      cartState.removeProduct(1); // +1
      cartState.clear(); // +1

      expect(listenerCalls, 4);
    });
  });
}
