import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/data/products.dart';
import 'package:app_compra_venta_electricos/models/product.dart';

void main() {
  group('Fase 1 - Auditoría de Imágenes de Productos', () {
    final List<Product> products = buildSampleProducts();

    test('Cada producto tiene imageAsset asignado y no vacío', () {
      expect(products, isNotEmpty);
      for (final product in products) {
        expect(
          product.imageAsset,
          isNotNull,
          reason: 'El producto ${product.sku} debe tener imageAsset',
        );
        expect(
          product.imageAsset!.isNotEmpty,
          isTrue,
          reason: 'El imageAsset del producto ${product.sku} no debe estar vacío',
        );
      }
    });

    test('Cada archivo de imageAsset existe físicamente en el disco', () {
      for (final product in products) {
        final file = File(product.imageAsset!);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'El archivo de imagen ${product.imageAsset} para ${product.sku} debe existir en el disco',
        );
      }
    });

    test('Ningún par de SKU comparte archivo de imagen salvo imageGroup declarado', () {
      final Map<String, List<Product>> assetToProducts = {};
      for (final product in products) {
        assetToProducts.putIfAbsent(product.imageAsset!, () => []).add(product);
      }

      for (final entry in assetToProducts.entries) {
        final sharedList = entry.value;
        if (sharedList.length > 1) {
          // Si comparten archivo, todos deben tener el mismo imageGroup y no ser nulo
          final firstGroup = sharedList.first.imageGroup;
          expect(
            firstGroup,
            isNotNull,
            reason: 'Los productos que comparten ${entry.key} deben declarar imageGroup. SKUs: ${sharedList.map((p) => p.sku).toList()}',
          );
          for (final p in sharedList) {
            expect(
              p.imageGroup,
              equals(firstGroup),
              reason: 'El producto ${p.sku} debe compartir el mismo imageGroup ($firstGroup)',
            );
          }
        }
      }
    });

    test('CREDITS.md tiene una fila de atribución por cada imagen de producto', () {
      final creditsFile = File('assets/images/products/CREDITS.md');
      expect(creditsFile.existsSync(), isTrue, reason: 'CREDITS.md debe existir');

      final content = creditsFile.readAsStringSync();
      for (final product in products) {
        expect(
          content.contains(product.sku),
          isTrue,
          reason: 'CREDITS.md debe contener una fila para el SKU ${product.sku}',
        );
      }
    });
  });
}
