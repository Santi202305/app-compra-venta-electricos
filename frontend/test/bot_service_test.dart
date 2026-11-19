import 'package:flutter_test/flutter_test.dart';

import 'package:app_compra_venta_electricos/data/products.dart';
import 'package:app_compra_venta_electricos/models/product.dart';
import 'package:app_compra_venta_electricos/services/bot_service.dart';
import 'package:app_compra_venta_electricos/services/local_bot_service.dart';

void main() {
  group('Fase 5 - Chatbot Técnico Inteligente Local (BotService / LocalBotService)', () {
    late LocalBotService bot;
    late List<Product> catalog;
    late BotContext context;

    setUp(() {
      bot = const LocalBotService();
      catalog = buildSampleProducts();
      context = BotContext(catalog: catalog);
    });

    test('1. Recomendación técnica: cable para acometida 220V', () async {
      final reply = await bot.reply('necesito cable para una acometida de 220v', context);
      expect(reply.intent, BotIntent.recommendation);
      expect(reply.text.toLowerCase(), contains('acometida'));
      expect(reply.text.toLowerCase(), contains('thhn'));
      expect(reply.products, isNotEmpty);
      expect(reply.products.any((p) => p.category == ProductCategory.cables), isTrue);
    });

    test('2. Disponibilidad de breakers de 20A', () async {
      final reply = await bot.reply('tienen breakers de 20 amperios?', context);
      expect(reply.intent, anyOf(BotIntent.stock, BotIntent.recommendation));
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'BRK-220-20A');
      expect(reply.text, contains('BRK-220-20A'));
    });

    test('3. Precio de taco de 1 polo', () async {
      final reply = await bot.reply('cuanto vale el taco schneider de 1 polo?', context);
      expect(reply.intent, BotIntent.price);
      expect(reply.products, isNotEmpty);
      expect(reply.products.any((p) => p.sku == 'BRK-110-32A'), isTrue);
      expect(reply.text, contains('\$'));
    });

    test('4. Precio de alambre calibre 12 por metro', () async {
      final reply = await bot.reply('a como el metro de alambre 12?', context);
      expect(reply.intent, BotIntent.price);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'CBL-THN-12');
      expect(reply.text, contains('3.200'));
    });

    test('5. Comparativa técnica entre cable 10 y cable 12', () async {
      final reply = await bot.reply('que diferencia hay entre cable 10 y cable 12?', context);
      expect(reply.intent, BotIntent.comparison);
      expect(reply.comparisonTable, isNotNull);
      final table = reply.comparisonTable!;
      expect(table.containsKey('Producto'), isTrue);
      expect(table.containsKey('Precio unitario'), isTrue);
      expect(reply.products.length, greaterThanOrEqualTo(2));
      expect(reply.products.any((p) => p.sku == 'CBL-THN-10'), isTrue);
      expect(reply.products.any((p) => p.sku == 'CBL-THN-12'), isTrue);
    });

    test('6. Búsqueda de cinta aislante 3M', () async {
      final reply = await bot.reply('¿venden cinta aislante 3m?', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'HTL-CIN-18');
      expect(reply.text.toLowerCase(), contains('cinta'));
    });

    test('7. Disponibilidad de multímetro digital', () async {
      final reply = await bot.reply('tienen disponible el multimetro?', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'HTL-MULT-3');
      expect(reply.text.toLowerCase(), contains('multímetro'));
    });

    test('8. Consulta de envíos a Soacha y Sabana', () async {
      final reply = await bot.reply('¿hacen envios a soacha?', context);
      expect(reply.intent, BotIntent.shipping);
      expect(reply.text.toLowerCase(), contains('soacha'));
      expect(reply.text.toLowerCase(), contains('bogotá'));
      expect(reply.text, contains('12.000'));
    });

    test('9. Consulta de método de pago contraentrega', () async {
      final reply = await bot.reply('¿puedo pagar contraentrega?', context);
      expect(reply.intent, BotIntent.payment);
      expect(reply.text.toLowerCase(), contains('contraentrega'));
      expect(reply.text.toLowerCase(), contains('efecty'));
    });

    test('10. Garantía técnica de herramientas', () async {
      final reply = await bot.reply('¿que garantia tienen las herramientas?', context);
      expect(reply.intent, BotIntent.warranty);
      expect(reply.text.toLowerCase(), contains('herramientas'));
      expect(reply.text, contains('6 meses'));
    });

    test('11. Seguimiento contextual: "¿y en 30 amperios?"', () async {
      // Primero pregunta por breakers de 20A
      await bot.reply('tienen breakers de 20 amperios?', context);
      expect(context.lastMentionedProduct?.sku, 'BRK-220-20A');

      // Pregunta elíptica contextual cambiando amperaje
      final followup = await bot.reply('y en 30 amperios?', context);
      expect(followup.intent, BotIntent.recommendation);
      expect(followup.products, isNotEmpty);
      expect(followup.products.first.sku, 'BRK-110-32A');
      expect(followup.text, contains('32A'));
    });

    test('12. Seguimiento contextual: "¿cuánto vale ese?"', () async {
      // Primero consulta un producto
      await bot.reply('a como el metro de alambre 12?', context);
      expect(context.lastMentionedProduct?.sku, 'CBL-THN-12');

      // Pregunta por el precio de ese producto
      final followup = await bot.reply('¿cuanto vale ese?', context);
      expect(followup.intent, BotIntent.price);
      expect(followup.products.first.sku, 'CBL-THN-12');
      expect(followup.text, contains('3.200'));
    });

    test('13. Seguimiento contextual: "¿tienen en stock?"', () async {
      await bot.reply('tienen disponible el multimetro?', context);
      expect(context.lastMentionedProduct?.sku, 'HTL-MULT-3');

      final followup = await bot.reply('¿tienen en stock?', context);
      expect(followup.intent, BotIntent.stock);
      expect(followup.text, contains('HTL-MULT-3'));
      expect(followup.text.toLowerCase(), contains('disponibles'));
    });

    test('14. Horario de atención al público', () async {
      final reply = await bot.reply('horario de atencion', context);
      expect(reply.intent, BotIntent.hours);
      expect(reply.text, contains('7:30 a.m.'));
      expect(reply.text, contains('6:00 p.m.'));
    });

    test('15. Solicitud de hablar con un asesor técnico humano', () async {
      final reply = await bot.reply('quiero hablar con un asesor', context);
      expect(reply.intent, BotIntent.agent);
      expect(reply.needsHumanAgent, isTrue);
      expect(reply.actions.any((a) => a.actionKey == 'contact_whatsapp'), isTrue);
    });

    test('16. Respuesta honesta sin alucinación para producto fuera de catálogo', () async {
      final reply = await bot.reply('¿tienen paneles solares de 500w?', context);
      expect(reply.intent, BotIntent.unknown);
      expect(reply.text, contains('No tengo esa información en mi catálogo técnico'));
      expect(reply.needsHumanAgent, isTrue);
      expect(reply.actions.any((a) => a.actionKey == 'contact_whatsapp'), isTrue);
      expect(reply.products, isEmpty);
    });

    // --- 10 Casos Adicionales con Argot y Casos Reales Colombianos ---

    test('17. Consulta de tomacorriente GFCI para áreas húmedas', () async {
      final reply = await bot.reply('¿tienen tomacorriente con proteccion gfci para cocina?', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'TMC-GFC-15A');
      expect(reply.text.toLowerCase(), contains('gfci'));
    });

    test('18. Supresor de picos DPS para tablero', () async {
      final reply = await bot.reply('necesito un dps supresor de sobretensiones para el tablero', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'PRT-DPS-20K');
    });

    test('19. Contactor modular de 25A', () async {
      final reply = await bot.reply('precio del contactor modular de 25a', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'CNT-MOD-25A');
      expect(reply.text, contains('CNT-MOD-25A'));
    });

    test('20. Herramienta para soldar: cautín eléctrico', () async {
      final reply = await bot.reply('¿venden cautin para soldar?', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'HTL-CAU-60W');
    });

    test('21. Ponchadora para terminales de cable', () async {
      final reply = await bot.reply('tienen ponchadora de terminales?', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'HTL-PNC-HDR');
    });

    test('22. Cable #14 AWG para iluminación', () async {
      final reply = await bot.reply('necesito cable numero 14 para iluminacion', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'CBL-THN-14');
    });

    test('23. Totalizador de 40A para acometida', () async {
      final reply = await bot.reply('tienen totalizador de 40 amperios', context);
      expect(reply.products, isNotEmpty);
      expect(reply.products.first.sku, 'BRK-TOT-40A');
    });

    test('24. Despacho y flete en Bogotá', () async {
      final reply = await bot.reply('¿cuanto demora el envio en bogota?', context);
      expect(reply.intent, BotIntent.shipping);
      expect(reply.text.toLowerCase(), contains('bogotá'));
      expect(reply.text.toLowerCase(), contains('mismo día'));
    });

    test('25. Transformador de 50 kVA (fuera de inventario -> respuesta honesta)', () async {
      final reply = await bot.reply('¿tienen transformador de 50 kva en aceite?', context);
      expect(reply.intent, BotIntent.unknown);
      expect(reply.needsHumanAgent, isTrue);
      expect(reply.text, contains('No tengo esa información'));
    });

    test('26. Cortesía y despedida en jerga coloquial', () async {
      final reply = await bot.reply('gracias compadre muy amable', context);
      expect(reply.intent, BotIntent.greeting);
      expect(reply.text, contains('mayor gusto'));
    });
  });
}
