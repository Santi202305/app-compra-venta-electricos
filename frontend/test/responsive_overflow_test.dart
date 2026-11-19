import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/screens/about_screen.dart';
import 'package:app_compra_venta_electricos/screens/cart_screen.dart';
import 'package:app_compra_venta_electricos/screens/home_screen.dart';
import 'package:app_compra_venta_electricos/screens/product_detail_screen.dart';
import 'package:app_compra_venta_electricos/state/app_state.dart';
import 'package:app_compra_venta_electricos/theme/app_theme.dart';

void main() {
  const List<Size> testSizes = [
    Size(360, 640), // 1. Móvil compacto
    Size(768, 1024), // 2. Tablet vertical
    Size(1366, 768), // 3. Laptop estándar
    Size(1920, 1080), // 4. Monitor Desktop Full HD
  ];

  Widget buildTestableWidget(Widget child, Size size) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    );
  }

  group('Fase 3 - Verificación de Responsive sin Overflow en los 4 tamaños clave', () {
    for (final size in testSizes) {
      final sizeLabel = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('HomeScreen no tiene overflow en $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final app = AppState();
        await tester.pumpWidget(buildTestableWidget(HomeScreen(app: app), size));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'HomeScreen tuvo overflow en $sizeLabel');
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('ProductDetailScreen no tiene overflow en $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final app = AppState();
        final product = app.products.first;

        await tester.pumpWidget(
          buildTestableWidget(ProductDetailScreen(product: product, app: app), size),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'ProductDetailScreen tuvo overflow en $sizeLabel');
        expect(find.byType(ProductDetailScreen), findsOneWidget);
      });

      testWidgets('CartScreen no tiene overflow con ítems en $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final app = AppState();
        app.cart.addProduct(app.products[0], 2);
        app.cart.addProduct(app.products[1], 1);

        await tester.pumpWidget(buildTestableWidget(CartScreen(app: app), size));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'CartScreen tuvo overflow en $sizeLabel');
        expect(find.byType(CartScreen), findsOneWidget);
      });

      testWidgets('AboutScreen no tiene overflow en $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const AboutScreen(), size));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'AboutScreen tuvo overflow en $sizeLabel');
        expect(find.byType(AboutScreen), findsOneWidget);
      });
    }
  });
}
