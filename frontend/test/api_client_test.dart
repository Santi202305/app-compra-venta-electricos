import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_compra_venta_electricos/api/api_client.dart';
import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/repositories/product_repository.dart';
import 'package:app_compra_venta_electricos/repositories/order_repository.dart';
import 'package:app_compra_venta_electricos/state/cart_state.dart';

void main() {
  group('ApiClient Tests', () {
    test('get() decodifica respuesta exitosa 200 JSON', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/products');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 1,
                'name': 'Breaker 20A',
                'sku': 'BRK-20A',
                'category': 'proteccion',
                'price': 38900,
                'stock': 10,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final response = await apiClient.get('/products');

      expect(response, isA<Map<String, dynamic>>());
      expect(response['success'], isTrue);
      expect(response['data'], isA<List<dynamic>>());
    });

    test('get() lanza ApiException en error 404 del backend', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'code': 'PRODUCT_NOT_FOUND',
              'message': 'Producto no encontrado',
            },
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get('/products/999'),
        throwsA(isA<ApiException>().having(
          (e) => e.code,
          'code',
          'PRODUCT_NOT_FOUND',
        )),
      );
    });
  });

  group('ProductRepository Tests', () {
    test('getProducts() consume API REST correctamente', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 50,
                'name': 'DPS 20kA Monofásico',
                'sku': 'DPS-20KA',
                'category': 'proteccion',
                'price': 78000,
                'stock': 5,
                'retieCompliant': true,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = ProductRepository(apiClient: ApiClient(client: mockClient));
      final products = await repository.getProducts(category: ProductCategory.proteccion);

      expect(products.length, 1);
      expect(products.first.id, 50);
      expect(products.first.name, 'DPS 20kA Monofásico');
      expect(products.first.retieCompliant, isTrue);
    });

    test('getProducts() realiza fallback a catálogo local si API falla', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });

      final repository = ProductRepository(apiClient: ApiClient(client: mockClient));
      final products = await repository.getProducts();

      expect(products.isNotEmpty, isTrue);
      expect(products.length, greaterThanOrEqualTo(5));
    });
  });

  group('OrderRepository Tests', () {
    test('submitOrder() procesa orden y devuelve número de guía ELC', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'ord_12345',
              'trackingNumber': 'ELC-20261118-8888',
              'total': 50900,
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final cartState = CartState();
      cartState.addProduct(
        const Product(
          id: 1,
          category: ProductCategory.proteccion,
          name: 'Breaker',
          sku: 'BRK',
          price: 38900,
        ),
        1,
      );

      final repository = OrderRepository(apiClient: ApiClient(client: mockClient));
      final result = await repository.submitOrder(
        cartState: cartState,
        customerName: 'Santiago Tech Lead',
        customerEmail: 'santiago@uceva.edu.co',
        shippingAddress: 'Tuluá, Valle',
        paymentMethod: 'nequi',
      );

      expect(result.success, isTrue);
      expect(result.trackingNumber, 'ELC-20261118-8888');
      expect(result.orderId, 'ord_12345');
    });
  });
}
