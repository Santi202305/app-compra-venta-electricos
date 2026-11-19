import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_compra_venta_electricos/models/app_user.dart';
import 'package:app_compra_venta_electricos/models/order.dart';
import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/services/shared_preferences_storage_service.dart';
import 'package:app_compra_venta_electricos/state/app_state.dart';
import 'package:app_compra_venta_electricos/state/cart_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fase 7 - Persistencia Local Offline-First (SharedPreferencesStorageService y AppState)', () {
    late SharedPreferencesStorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = const SharedPreferencesStorageService();
    });

    test('1. SharedPreferencesStorageService guarda y carga el carrito correctamente', () async {
      final p1 = Product(
        id: 1,
        category: ProductCategory.proteccion,
        name: 'Breaker 20A',
        sku: 'BRK-220-20A',
        price: 38900,
        stock: 10,
      );
      final p2 = Product(
        id: 2,
        category: ProductCategory.cables,
        name: 'Cable THHN #12',
        sku: 'CBL-THN-12',
        price: 3200,
        stock: 50,
      );

      final cartItems = [
        CartEntry(p1, 2),
        CartEntry(p2, 15),
      ];

      await storageService.saveCart(cartItems);

      final loaded = await storageService.loadCart();
      expect(loaded.length, 2);
      expect(loaded[0]['sku'], 'BRK-220-20A');
      expect(loaded[0]['qty'], 2);
      expect(loaded[1]['sku'], 'CBL-THN-12');
      expect(loaded[1]['qty'], 15);
    });

    test('2. SharedPreferencesStorageService guarda y carga órdenes con trazabilidad completa', () async {
      final order = Order(
        id: 1005,
        date: DateTime(2026, 11, 12, 10, 30),
        userEmail: 'electricista@obra.com',
        lines: const [
          OrderLine(
            productName: 'Breaker DIN 20A',
            sku: 'BRK-220-20A',
            unitPrice: 38900,
            qty: 3,
          ),
        ],
        subtotal: 116700,
        shipping: 12000,
        paymentLabel: 'Nequi',
        address: 'Calle 100 # 15-20, Bogotá',
        status: OrderStatus.enCamino,
      );

      await storageService.saveOrders([order]);

      final loadedOrders = await storageService.loadOrders();
      expect(loadedOrders.length, 1);
      final o = loadedOrders.first;
      expect(o.id, 1005);
      expect(o.userEmail, 'electricista@obra.com');
      expect(o.lines.length, 1);
      expect(o.lines.first.sku, 'BRK-220-20A');
      expect(o.status, OrderStatus.enCamino);
      expect(o.total, 116700 + 12000);
    });

    test('3. SharedPreferencesStorageService guarda, recupera y borra sesión de usuario', () async {
      const user = AppUser(
        name: 'Ing. Carlos Mendoza',
        email: 'carlos.mendoza@ingenieria.co',
        password: '',
        isAdmin: true,
      );

      await storageService.saveUser(user);

      final loadedUser = await storageService.loadUser();
      expect(loadedUser, isNotNull);
      expect(loadedUser!.name, 'Ing. Carlos Mendoza');
      expect(loadedUser.email, 'carlos.mendoza@ingenieria.co');
      expect(loadedUser.isAdmin, isTrue);

      // Borrar sesión
      await storageService.saveUser(null);
      final emptyUser = await storageService.loadUser();
      expect(emptyUser, isNull);
    });

    test('4. AppState.initPersistence() rehidrata sesión de usuario, pedidos y carrito en arranque', () async {
      // 1. Sembrar almacenamiento local previo
      const storedUser = AppUser(
        name: 'Contratista Mario',
        email: 'mario@instalaciones.com',
        password: '',
        isAdmin: false,
      );
      await storageService.saveUser(storedUser);

      final storedOrder = Order(
        id: 2001,
        date: DateTime.now(),
        userEmail: 'mario@instalaciones.com',
        lines: const [
          OrderLine(productName: 'Cable 12', sku: 'CBL-THN-12', unitPrice: 3200, qty: 10),
        ],
        subtotal: 32000,
        shipping: 12000,
        paymentLabel: 'Contraentrega',
        address: 'Carrera 7 # 45-12',
      );
      await storageService.saveOrders([storedOrder]);

      // Carrito con 1 producto
      await storageService.saveCart([
        CartEntry(
          Product(
            id: 1,
            category: ProductCategory.proteccion,
            name: 'Breaker DIN 20A Bipolar',
            sku: 'BRK-220-20A',
            price: 38900,
            stock: 24,
          ),
          2,
        ),
      ]);

      // 2. Iniciar nueva instancia de AppState
      final app = AppState(storageService: storageService);
      expect(app.isLoggedIn, isFalse);
      expect(app.cart.items, isEmpty);

      // 3. Ejecutar rehidratación offline
      await app.initPersistence();

      expect(app.isLoggedIn, isTrue);
      expect(app.currentUser?.email, 'mario@instalaciones.com');
      expect(app.allOrders.length, 1);
      expect(app.allOrders.first.id, 2001);
      expect(app.cart.items.length, 1);
      expect(app.cart.items.first.product.sku, 'BRK-220-20A');
      expect(app.cart.items.first.qty, 2);
    });

    test('5. AppState persiste automáticamente cambios en el carrito al agregar ítems', () async {
      final app = AppState(storageService: storageService);
      await app.initPersistence();

      final product = app.products.first;
      app.cart.addProduct(product, 3);

      // Espera ciclo asíncrono
      await Future.delayed(const Duration(milliseconds: 50));

      final persisted = await storageService.loadCart();
      expect(persisted.isNotEmpty, isTrue);
      expect(persisted.first['sku'], product.sku);
      expect(persisted.first['qty'], 3);
    });
  });
}
