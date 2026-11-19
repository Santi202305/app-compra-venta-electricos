import 'package:flutter_test/flutter_test.dart';

import 'package:app_compra_venta_electricos/models/order.dart';
import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/services/secure_sales_service.dart';
import 'package:app_compra_venta_electricos/services/token_storage_service.dart';
import 'package:app_compra_venta_electricos/state/app_state.dart';

void main() {
  group('Autenticación y registro', () {
    test('rechaza credenciales incorrectas y acepta las correctas', () async {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      expect(await app.login('cliente@correo.com', 'mala'), isNotNull);
      expect(app.isLoggedIn, isFalse);
      expect(await app.login('cliente@correo.com', 'cliente123'), isNull);
      expect(app.isLoggedIn, isTrue);
      expect(app.isAdmin, isFalse);
      expect(app.hasToken, isTrue);
    });

    test('el administrador entra con su cuenta', () async {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      expect(await app.login('admin@negocio.com', 'admin123'), isNull);
      expect(app.isAdmin, isTrue);
      expect(app.hasToken, isTrue);
    });

    test('registro valida correo, contraseña y duplicados', () async {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      expect(
        await app.register(name: 'Ana', email: 'sin-arroba', password: '123456'),
        isNotNull,
      );
      expect(
        await app.register(name: 'Ana', email: 'ana@correo.com', password: '123'),
        isNotNull,
      );
      expect(
        await app.register(name: 'Ana', email: 'ana@correo.com', password: '123456'),
        isNull,
      );
      expect(
        await app.register(name: 'Ana', email: 'ana@correo.com', password: '123456'),
        isNotNull,
      );
    });
  });

  group('Carrito, stock y pedidos', () {
    test('no permite agregar más unidades que el stock', () {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      final soldOut = app.products
          .firstWhere((p) => p.stockStatus == StockStatus.agotado);
      expect(app.cart.addProduct(soldOut, 1), isFalse);

      final limited = app.products.firstWhere((p) => p.stock == 2);
      expect(app.cart.addProduct(limited, 3), isFalse);
      expect(app.cart.addProduct(limited, 2), isTrue);
      expect(app.cart.addProduct(limited, 1), isFalse);
    });

    test('crear un pedido descuenta el stock y vacía el carrito', () async {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      await app.login('cliente@correo.com', 'cliente123');
      final product = app.products.first;
      final before = product.stock;

      expect(app.cart.addProduct(product, 2), isTrue);
      final order = app.placeOrder(
        paymentLabel: 'Nequi',
        address: 'Calle 25 # 10-20',
      );

      expect(order, isNotNull);
      expect(product.stock, before - 2);
      expect(app.cart.items, isEmpty);
      expect(app.myOrders.length, 1);
      expect(app.allOrders.length, 1);
      expect(order!.status, OrderStatus.pendiente);
    });

    test('sin productos en el carrito no se crea pedido', () {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      expect(app.placeOrder(paymentLabel: 'Nequi', address: 'x'), isNull);
    });
  });

  group('Panel administrativo', () {
    test('permite actualizar stock y precio', () {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      final product = app.products.first;
      app.updateProduct(product, stock: 99, price: 50000);
      expect(product.stock, 99);
      expect(product.price, 50000);
    });

    test('permite cambiar el estado de un pedido', () async {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      await app.login('cliente@correo.com', 'cliente123');
      app.cart.addProduct(app.products.first, 1);
      final order = app.placeOrder(paymentLabel: 'Nequi', address: 'x')!;

      app.setOrderStatus(order, OrderStatus.enCamino);
      expect(order.status, OrderStatus.enCamino);
      app.setOrderStatus(order, OrderStatus.entregado);
      expect(order.status, OrderStatus.entregado);
    });
  });

  group('Ventas seguras y Voucher encriptado', () {
    test('genera voucher con token encriptado y envío por correo', () async {
      final app = AppState(tokenStorage: InMemoryTokenStorageService());
      await app.login('cliente@correo.com', 'cliente123');
      app.cart.addProduct(app.products.first, 1);
      final order = app.placeOrder(paymentLabel: 'Nequi', address: 'Calle 25')!;

      final voucher = await SecureSalesService.instance.processSecureSale(
        order: order,
        customerEmail: 'comprador@correo.com',
      );

      expect(voucher.orderId, order.id);
      expect(voucher.authorizationCode.startsWith('AUTH-SEC-'), isTrue);
      expect(voucher.securitySignature.isNotEmpty, isTrue);
      expect(voucher.encryptedTransactionToken.isNotEmpty, isTrue);
      expect(voucher.emailSent, isTrue);
      expect(voucher.emailRecipient, 'comprador@correo.com');
      expect(voucher.total, order.total);
      expect(voucher.subtotal + voucher.iva, order.subtotal);

      final cached = SecureSalesService.instance.getVoucherForOrder(order.id);
      expect(cached, isNotNull);
      expect(cached!.authorizationCode, voucher.authorizationCode);
    });
  });
}
