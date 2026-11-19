import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/data/products.dart';
import 'package:app_compra_venta_electricos/models/product.dart';

void main() {
  group('Fase 2 - Descripciones Técnicas y Especificaciones Estructuradas', () {
    final List<Product> products = buildSampleProducts();

    test('Los 35 productos tienen shortDescription no vacía y <= 100 caracteres', () {
      expect(products.length, equals(35));
      for (final p in products) {
        expect(
          p.shortDescription.isNotEmpty,
          isTrue,
          reason: 'El SKU ${p.sku} debe tener shortDescription no vacía',
        );
        expect(
          p.shortDescription.length,
          lessThanOrEqualTo(100),
          reason: 'El SKU ${p.sku} tiene una shortDescription de ${p.shortDescription.length} caracteres (> 100)',
        );
      }
    });

    test('Los 35 productos tienen longDescription técnica con al menos 2 oraciones', () {
      for (final p in products) {
        expect(
          p.longDescription.isNotEmpty,
          isTrue,
          reason: 'El SKU ${p.sku} debe tener longDescription no vacía',
        );
        final sentenceCount = p.longDescription.split('.').where((s) => s.trim().isNotEmpty).length;
        expect(
          sentenceCount,
          greaterThanOrEqualTo(2),
          reason: 'El SKU ${p.sku} debe tener al menos 2 oraciones en longDescription (tiene $sentenceCount)',
        );
      }
    });

    test('Los 35 productos tienen mapa de specs estructurado con al menos 3 parámetros', () {
      for (final p in products) {
        expect(
          p.specs.isNotEmpty,
          isTrue,
          reason: 'El SKU ${p.sku} debe tener specs no vacío',
        );
        expect(
          p.specs.length,
          greaterThanOrEqualTo(3),
          reason: 'El SKU ${p.sku} debe tener al menos 3 parámetros en specs',
        );
      }
    });

    test('Los 35 productos tienen applications con al menos 2 casos de uso', () {
      for (final p in products) {
        expect(
          p.applications.length,
          greaterThanOrEqualTo(2),
          reason: 'El SKU ${p.sku} debe tener al menos 2 aplicaciones típicas',
        );
      }
    });

    test('Productos críticos de potencia (breakers, GFCI, DPS, cables) contienen advertencia RETIE', () {
      final criticalPrefixes = ['BRK-', 'PRT-', 'TMC-', 'CBL-THN', 'CBL-DES'];
      for (final p in products) {
        if (criticalPrefixes.any((prefix) => p.sku.startsWith(prefix))) {
          final text = '${p.longDescription} ${(p.standards ?? []).join(" ")}';
          expect(
            text.contains('RETIE'),
            isTrue,
            reason: 'El producto crítico ${p.sku} debe mencionar RETIE en su descripción o normas',
          );
        }
      }
    });

    test('Product.copyWith funciona de manera inmutable', () {
      final original = products.first;
      final modified = original.copyWith(price: 99999, stock: 1);

      expect(modified.price, equals(99999));
      expect(modified.stock, equals(1));
      expect(original.price, isNot(equals(99999)));
      expect(original.id, equals(modified.id));
      expect(original.sku, equals(modified.sku));
    });
  });
}
