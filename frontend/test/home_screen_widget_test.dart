import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/repositories/product_repository.dart';
import 'package:app_compra_venta_electricos/screens/home_screen.dart';
import 'package:app_compra_venta_electricos/state/cart_state.dart';

class MockProductRepository extends ProductRepository {
  final List<Product> mockProducts;

  MockProductRepository(this.mockProducts);

  @override
  Future<List<Product>> getProducts({ProductCategory? category, String? search}) async {
    if (category != null && category != ProductCategory.todos) {
      return mockProducts.where((p) => p.category == category).toList();
    }
    return mockProducts;
  }
}

void main() {
  testWidgets('HomeScreen renderiza catálogo y actualiza badge de carrito', (WidgetTester tester) async {
    final mockProducts = [
      const Product(
        id: 1,
        category: ProductCategory.proteccion,
        name: 'Breaker DIN 20A',
        sku: 'BRK-20A',
        price: 38900,
      ),
      const Product(
        id: 2,
        category: ProductCategory.cables,
        name: 'Cable THHN #12',
        sku: 'CBL-12',
        price: 3200,
      ),
    ];

    final cartState = CartState();
    final repository = MockProductRepository(mockProducts);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          cartState: cartState,
          repository: repository,
        ),
      ),
    );

    // Esperar resolución de Futures y renderizado inicial
    await tester.pumpAndSettle();

    // 1. Verificar título de la aplicación
    expect(find.text('Catálogo Electro'), findsOneWidget);

    // 2. Verificar que los chips de categorías existen
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Protección'), findsOneWidget);
    expect(find.text('Cables'), findsOneWidget);

    // 3. Verificar que los productos se renderizan
    expect(find.text('Breaker DIN 20A'), findsOneWidget);
    expect(find.text('Cable THHN #12'), findsOneWidget);

    // 4. Agregar al carrito y verificar actualización reactiva del badge
    final addButtons = find.byIcon(Icons.add);
    expect(addButtons, findsNWidgets(2));

    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    expect(cartState.totalItems, 1);
    expect(find.text('1'), findsOneWidget); // Badge del carrito muestra 1
  });
}
