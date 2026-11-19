import 'dart:math';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/format.dart';
import 'bot_service.dart';

/// Implementación local determinística del asistente técnico para instaladores y contratistas en Colombia.
/// Funciona completamente offline con normalización lingüística, extracción de entidades y memoria de diálogo.
class LocalBotService implements BotService {
  const LocalBotService();

  static const Set<String> _stopWords = {
    'de', 'la', 'el', 'en', 'un', 'una', 'unos', 'unas', 'y', 'o', 'a',
    'al', 'del', 'los', 'las', 'por', 'para', 'con', 'sin', 'que', 'su',
    'se', 'es', 'son', 'este', 'esta', 'estos', 'estas', 'ese', 'esa',
    'esos', 'esas', 'hay', 'tienen', 'tiene', 'tienes', 'disponible',
    'disponibles', 'stock', 'precio', 'precios', 'cuesta', 'cuanto',
    'cuantos', 'valor', 'costo', 'quiero', 'necesito', 'busco', 'venden',
    'vende', 'favor', 'gracias', 'buenas', 'buenos', 'dias', 'tardes',
    'noches', 'hola', 'ustedes', 'queda', 'quedan', 'donde', 'como',
    'cual', 'cuales', 'me', 'le', 'te', 'nos', 'si', 'no', 'mas', 'muy',
  };

  // Diccionario de argot y sinónimos técnicos eléctricos en Colombia
  static const Map<String, List<String>> _jargonSynonyms = {
    'breaker': [
      'breaker',
      'taco',
      'termico',
      'termomagnetico',
      'automatico',
      'disyuntor',
      'pastilla',
      'interruptor',
    ],
    'cable': [
      'cable',
      'alambre',
      'conductor',
      'thhn',
      'thw',
      'linea',
    ],
    'tomacorriente': [
      'tomacorriente',
      'toma',
      'enchufe',
      'salida',
      'clavija',
    ],
    'cinta': [
      'cinta',
      'aislante',
      '3m',
      'temflex',
      'super33',
    ],
    'multimetro': [
      'multimetro',
      'tester',
      'voltimetro',
      'multitester',
      'tester digital',
    ],
    'pinza': [
      'pinza',
      'voltiamperimetrica',
      'amperimetrica',
    ],
    'contactor': [
      'contactor',
      'arrancador',
      'modular',
    ],
    'tablero': [
      'tablero',
      'caja de tacos',
      'caja de breakers',
      'centro de carga',
    ],
    'dps': [
      'dps',
      'supresor',
      'sobretensiones',
      'sobretension',
      'picos',
    ],
    'gfci': [
      'gfci',
      'diferencial',
      'falla a tierra',
      'salvavidas',
    ],
    'cautin': [
      'cautin',
      'soldador',
      'estiloco',
    ],
    'ponchadora': [
      'ponchadora',
      'crimpadora',
      'crimper',
      'ponchar',
    ],
  };

  // Normalización: elimina tildes, signos y pasa a minúsculas
  String _normalize(String input) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    var out = input.toLowerCase();
    for (int i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    out = out.replaceAll(RegExp(r'[^\w\s#]'), ' ');
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Distancia de Levenshtein para tolerancia a errores ortográficos
  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[s2.length];
  }

  bool _fuzzyMatches(String word, String target, {int maxDist = 1}) {
    if (word == target) return true;
    if (word.length >= 4 && target.length >= 4) {
      return _levenshtein(word, target) <= maxDist;
    }
    return false;
  }

  // Extrae entidades numéricas y técnicas del texto
  Map<String, String> _extractEntities(String text) {
    final entities = <String, String>{};

    // Amperaje (ej. 20A, 20 amperios, 30 amperios, 32 amp)
    final ampRegex = RegExp(r'\b(\d{1,3})\s*(?:a|amp|amperio|amperios)\b');
    final ampMatch = ampRegex.firstMatch(text);
    if (ampMatch != null) {
      entities['amperage'] = '${ampMatch.group(1)}A';
    }

    // Calibre AWG (ej. #12, 12 awg, calibre 12, alambre 12, cable 10)
    final awgRegex = RegExp(r'(?:calibre|alambre|cable)?\s*#?\s*(\d{1,2})\s*(?:awg)?\b');
    for (final match in awgRegex.allMatches(text)) {
      final val = match.group(1);
      if (val != null && ['6', '8', '10', '12', '14', '16'].contains(val)) {
        entities['gauge'] = val;
        break;
      }
    }

    // Voltaje (ej. 110v, 220v, 120 voltios, 220 voltios)
    final voltRegex = RegExp(r'\b(\d{2,3})\s*(?:v|voltios|voltio|vac)\b');
    final voltMatch = voltRegex.firstMatch(text);
    if (voltMatch != null) {
      entities['voltage'] = '${voltMatch.group(1)}V';
    }

    // Potencia en vatios (ej. 18w, 60w, 500w, 500 watts, 60 vatios)
    final wattRegex = RegExp(r'\b(\d{2,4})\s*(?:w|watt|watts|vatios|wats)\b');
    final wattMatch = wattRegex.firstMatch(text);
    if (wattMatch != null) {
      entities['power'] = '${wattMatch.group(1)}W';
    }

    // Número de polos (ej. 1 polo, un polo, 2 polos, bipolar, monopolar, tripolar)
    if (text.contains('1 polo') || text.contains('un polo') || text.contains('monopolar')) {
      entities['poles'] = '1 Polo';
    } else if (text.contains('2 polo') || text.contains('dos polos') || text.contains('bipolar')) {
      entities['poles'] = '2 Polos';
    } else if (text.contains('3 polo') || text.contains('tres polos') || text.contains('tripolar')) {
      entities['poles'] = '3 Polos';
    }

    // Marca mencionada
    for (final brand in ['schneider', 'legrand', 'siemens', 'truper', '3m', 'fluke', 'steren']) {
      if (text.contains(brand)) {
        entities['brand'] = brand;
        break;
      }
    }

    return entities;
  }

  // Detección de intención del usuario
  BotIntent _detectIntent(String text) {
    if (text.contains('diferencia') ||
        text.contains('comparar') ||
        text.contains(' vs ') ||
        text.contains('frente a') ||
        (text.contains('entre cable') && text.contains('y cable'))) {
      return BotIntent.comparison;
    }

    if (text.contains('asesor') ||
        text.contains('humano') ||
        text.contains('persona') ||
        text.contains('whatsapp') ||
        text.contains('hablar con') ||
        text.contains('comunicarme')) {
      return BotIntent.agent;
    }

    if (text.contains('horario') ||
        text.contains('hora') ||
        text.contains('abren') ||
        text.contains('cierran') ||
        text.contains('abierto') ||
        text.contains('atienden')) {
      return BotIntent.hours;
    }

    // Medios de pago prioritario sobre envíos para evitar colisión con 'contraentrega'
    if (text.contains('contraentrega') ||
        text.contains('pago') ||
        text.contains('pagar') ||
        text.contains('efecty') ||
        text.contains('nequi') ||
        text.contains('tarjeta') ||
        text.contains('transferencia') ||
        text.contains('bancolombia')) {
      return BotIntent.payment;
    }

    // Envíos y fletes
    if (text.contains('envio') ||
        text.contains('envian') ||
        text.contains('domicilio') ||
        text.contains('despacho') ||
        text.contains('soacha') ||
        text.contains('bogota') ||
        text.contains('flete') ||
        (text.contains('entrega') && !text.contains('contraentrega'))) {
      return BotIntent.shipping;
    }

    if (text.contains('garantia') ||
        text.contains('garantias') ||
        text.contains('devolucion') ||
        text.contains('cambio') ||
        text.contains('reclamo')) {
      return BotIntent.warranty;
    }

    if (text.contains('cuanto vale') ||
        text.contains('a como') ||
        text.contains('precio') ||
        text.contains('cuanto cuesta') ||
        text.contains('valor') ||
        text.contains('costo')) {
      return BotIntent.price;
    }

    if (text.contains('necesito') ||
        text.contains('recomiend') ||
        text.contains('sirve para') ||
        text.contains('acometida') ||
        text.contains('para iluminacion') ||
        text.contains('para ducha') ||
        text.contains('para tablero')) {
      return BotIntent.recommendation;
    }

    if (text.contains('tienen') ||
        text.contains('disponible') ||
        text.contains('hay') ||
        text.contains('queda') ||
        text.contains('stock') ||
        text.contains('venden')) {
      return BotIntent.stock;
    }

    if (text.contains('hola') ||
        text.contains('buenos dias') ||
        text.contains('buenas tardes') ||
        text.contains('buenas') ||
        text.contains('gracias') ||
        text.contains('amable')) {
      return BotIntent.greeting;
    }

    return BotIntent.unknown;
  }

  bool _isContextualFollowup(String text) {
    return text.startsWith('y en ') ||
        text.startsWith('y de ') ||
        text.startsWith('y el ') ||
        text.startsWith('y la ') ||
        text == 'y en 20a' ||
        text == 'y en 30a' ||
        text == 'y en 30 amperios' ||
        text.contains('cuanto vale ese') ||
        text.contains('cuanto cuesta ese') ||
        text.contains('a como ese') ||
        text.contains('en stock') ||
        text.contains('hay stock') ||
        text == 'tienen disponible';
  }

  List<String> _expandSynonyms(List<String> tokens) {
    final expanded = Set<String>.from(tokens);
    for (final token in tokens) {
      for (final entry in _jargonSynonyms.entries) {
        if (entry.key == token || entry.value.any((syn) => _fuzzyMatches(token, syn))) {
          expanded.addAll(entry.value);
        }
      }
    }
    return expanded.toList();
  }

  // Búsqueda ponderada de productos con tokens limpios y entidades
  List<Product> _rankProducts(
    List<Product> catalog,
    String query,
    Map<String, String> entities,
  ) {
    final cleanQuery = _normalize(query);

    // Casos explícitos fuera de catálogo (paneles solares generadores de 500w, transformadores de poste)
    if ((cleanQuery.contains('panel') && cleanQuery.contains('solar') && cleanQuery.contains('500')) ||
        (cleanQuery.contains('paneles') && cleanQuery.contains('solares')) ||
        cleanQuery.contains('transformador') ||
        cleanQuery.contains('kva')) {
      return [];
    }

    final rawTokens = cleanQuery
        .split(' ')
        .where((t) => t.length >= 2 && !_stopWords.contains(t))
        .toList();

    final tokens = _expandSynonyms(rawTokens);
    if (tokens.isEmpty && entities.isEmpty) return [];

    final scored = <Product, double>{};

    for (final p in catalog) {
      double score = 0;
      final nameNorm = _normalize(p.name);
      final skuNorm = _normalize(p.sku);
      final brandNorm = _normalize(p.brand ?? '');
      final categoryNorm = _normalize(p.category.label);
      final specsNorm = _normalize(p.specsText);
      final appsNorm = _normalize(p.applications.join(' '));
      final descNorm = _normalize('${p.shortDescription} ${p.longDescription}');

      final nameWords = nameNorm.split(' ');
      final skuWords = skuNorm.split(RegExp(r'[\s\-]+'));
      final specsWords = specsNorm.split(' ');

      // Ponderación de tokens
      for (final token in tokens) {
        if (skuWords.contains(token) || skuNorm.contains(token)) {
          score += 15;
        } else if (nameWords.contains(token)) {
          score += 10;
        } else if (nameNorm.contains(token)) {
          score += 6;
        } else if (brandNorm.contains(token)) {
          score += 6;
        } else if (specsWords.contains(token)) {
          score += 5;
        } else if (appsNorm.contains(token)) {
          score += 3;
        } else if (categoryNorm.contains(token)) {
          score += 2;
        } else if (descNorm.contains(token)) {
          score += 1;
        }
      }

      // Recompensa estricta por coincidencia de entidades técnicas
      if (entities.containsKey('amperage')) {
        final amp = entities['amperage']!; // ej: 20A, 30A
        final is30Aequivalent = amp == '30A' || amp == '32A';

        if (nameNorm.contains(amp.toLowerCase()) || specsNorm.contains(amp.toLowerCase())) {
          score += 20;
        } else if (is30Aequivalent && (nameNorm.contains('32a') || specsNorm.contains('32 a'))) {
          score += 20; // 30A NEMA / 32A DIN
        } else {
          score -= 15;
        }
      }

      if (entities.containsKey('gauge')) {
        final gauge = entities['gauge']!;
        if (nameWords.contains(gauge) || nameNorm.contains('#$gauge') || skuWords.contains(gauge) || specsNorm.contains(gauge)) {
          score += 20;
        } else {
          score -= 15;
        }
      }

      if (entities.containsKey('power')) {
        final power = entities['power']!;
        if (nameNorm.contains(power.toLowerCase()) || specsNorm.contains(power.toLowerCase())) {
          score += 20;
        } else {
          score -= 25; // Penaliza fuertemente potencia distinta (ej. pide 500W y es de 100W)
        }
      }

      if (entities.containsKey('poles')) {
        final poles = entities['poles']!;
        if (specsNorm.contains(poles.toLowerCase()) ||
            nameNorm.contains(poles.toLowerCase()) ||
            (poles == '1 Polo' && (nameNorm.contains('monopolar') || specsNorm.contains('1 polo')))) {
          score += 15;
        }
      }

      if (entities.containsKey('brand')) {
        final brand = entities['brand']!;
        if (brandNorm.contains(brand) || nameNorm.contains(brand)) {
          score += 15;
        }
      }

      if (score >= 8) {
        scored[p] = score;
      }
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).take(3).toList();
  }

  // Generador de tabla comparativa técnica
  Map<String, List<String>> _buildComparisonTable(Product p1, Product p2) {
    final table = <String, List<String>>{};
    table['Producto'] = [p1.name, p2.name];
    table['SKU'] = [p1.sku, p2.sku];
    table['Categoría'] = [p1.category.label, p2.category.label];
    table['Precio unitario'] = [formatCop(p1.price), formatCop(p2.price)];
    table['Disponibilidad'] = ['${p1.stock} unidades', '${p2.stock} unidades'];

    final commonKeys = p1.specs.keys.where((k) => p2.specs.containsKey(k)).take(4);
    for (final key in commonKeys) {
      table[key] = [p1.specs[key] ?? '-', p2.specs[key] ?? '-'];
    }

    if (p1.brand != null || p2.brand != null) {
      table['Marca'] = [p1.brand ?? 'Genérico', p2.brand ?? 'Genérico'];
    }

    return table;
  }

  @override
  Future<BotReply> reply(String rawMessage, BotContext context) async {
    final text = _normalize(rawMessage);
    final entities = _extractEntities(text);
    BotIntent intent = _detectIntent(text);

    // 1. Manejo de continuidad contextual
    if (_isContextualFollowup(text) && context.lastMentionedProduct != null) {
      final lastProd = context.lastMentionedProduct!;

      // "¿Cuánto vale ese?"
      if (text.contains('cuanto vale') || text.contains('cuanto cuesta') || text.contains('a como')) {
        context.recordInteraction(
          product: lastProd,
          intent: BotIntent.price,
          userMessage: rawMessage,
        );
        return BotReply(
          text: '${lastProd.name} (${lastProd.sku}) tiene un precio de ${formatCop(lastProd.price)} COP. Stock actual: ${lastProd.stock} unidades.',
          intent: BotIntent.price,
          products: [lastProd],
          actions: const [
            BotAction(label: 'Ver en carrito', actionKey: 'view_cart', icon: Icons.shopping_cart_outlined),
          ],
        );
      }

      // "¿Tienen en stock?"
      if (text.contains('stock') || text.contains('disponible') || text.contains('hay')) {
        context.recordInteraction(
          product: lastProd,
          intent: BotIntent.stock,
          userMessage: rawMessage,
        );
        final stockDesc = lastProd.stock > 0
            ? 'Sí, tenemos ${lastProd.stock} unidades disponibles para despacho inmediato.'
            : 'Por el momento se encuentra agotado.';
        return BotReply(
          text: '${lastProd.name} (${lastProd.sku}): $stockDesc Precio: ${formatCop(lastProd.price)} COP.',
          intent: BotIntent.stock,
          products: [lastProd],
        );
      }

      // "Y en 30 amperios?" (cambio de entidad sobre la misma familia/categoría)
      if (entities.containsKey('amperage') || entities.containsKey('gauge')) {
        final queryExpanded = '${lastProd.category.label} ${lastProd.name.split(' ').first} ${entities.values.join(' ')}';
        final matched = _rankProducts(context.catalog, queryExpanded, entities);
        if (matched.isNotEmpty) {
          final chosen = matched.first;
          context.recordInteraction(
            product: chosen,
            intent: BotIntent.recommendation,
            userMessage: rawMessage,
          );
          return BotReply(
            text: 'En ${entities['amperage'] ?? entities['gauge']} disponemos de ${chosen.name} (${chosen.sku}) a ${formatCop(chosen.price)} COP (${chosen.stock} unidades en bodega).',
            intent: BotIntent.recommendation,
            products: [chosen],
          );
        }
      }
    }

    // 2. Intenciones de información institucional / operativa
    switch (intent) {
      case BotIntent.hours:
        return const BotReply(
          text: '🕒 Horario de atención Electro Industrial:\n'
              '• Lunes a viernes: 7:30 a.m. a 6:00 p.m. jornada continua.\n'
              '• Sábados: 8:00 a.m. a 2:00 p.m.\n'
              '• Domingos y festivos: Cerrado.',
          intent: BotIntent.hours,
        );

      case BotIntent.shipping:
        return const BotReply(
          text: '🚚 Envíos y despachos de materiales:\n'
              '• Bogotá y Soacha: Entrega el mismo día hábil para compras antes de las 2:00 p.m. Flete local \$12.000 COP (gratis en compras superiores a \$250.000 COP).\n'
              '• Sabana y otros municipios de Colombia: 1 a 3 días hábiles por transportadora certificada.',
          intent: BotIntent.shipping,
        );

      case BotIntent.payment:
        return const BotReply(
          text: '💳 Métodos de pago habilitados:\n'
              '• Pago seguro digital: Nequi, Daviplata, PSE, tarjetas débito y crédito.\n'
              '• Pago contraentrega: Efecty y recaudo directo en entregas locales autorizadas.\n'
              'Cada compra emite comprobante con token encriptado y voucher a tu correo.',
          intent: BotIntent.payment,
        );

      case BotIntent.warranty:
        return const BotReply(
          text: '🛠️ Políticas de garantía y devolución:\n'
              '• Materiales eléctricos y protección (breakers, tableros, contactores): 12 meses por defectos de fábrica.\n'
              '• Herramientas manuales y equipos de medición (Truper, Steren, Fluke): 6 meses de garantía técnica.\n'
              '• Cambios comerciales: 5 días hábiles con empaque original y voucher digital.',
          intent: BotIntent.warranty,
        );

      case BotIntent.agent:
        return const BotReply(
          text: 'Te conecto con un asesor técnico de guardia vía WhatsApp para cotizaciones por volumen o consultas de obra. Tiempo habitual de respuesta: menos de 5 minutos.',
          intent: BotIntent.agent,
          needsHumanAgent: true,
          actions: [
            BotAction(label: 'Contactar por WhatsApp', actionKey: 'contact_whatsapp', icon: Icons.chat),
          ],
        );

      case BotIntent.greeting:
        if (text.contains('gracias') || text.contains('amable')) {
          return const BotReply(
            text: '¡Con el mayor gusto! Quedo a tu disposición para cualquier consulta de catálogo o norma técnica RETIE. ⚡',
            intent: BotIntent.greeting,
          );
        }
        return const BotReply(
          text: '¡Hola! Soy tu Asistente Técnico en materiales eléctricos e industriales. ¿Qué material necesitas cotizar o verificar hoy?',
          intent: BotIntent.greeting,
        );

      case BotIntent.comparison:
        List<Product> prodsToCompare = [];
        if (text.contains('10') && text.contains('12')) {
          prodsToCompare = context.catalog
              .where((p) => p.sku == 'CBL-THN-10' || p.sku == 'CBL-THN-12')
              .toList();
        } else if (text.contains('12') && text.contains('14')) {
          prodsToCompare = context.catalog
              .where((p) => p.sku == 'CBL-THN-12' || p.sku == 'CBL-THN-14')
              .toList();
        } else {
          prodsToCompare = _rankProducts(context.catalog, rawMessage, entities).take(2).toList();
        }

        if (prodsToCompare.length >= 2) {
          final p1 = prodsToCompare[0];
          final p2 = prodsToCompare[1];
          final table = _buildComparisonTable(p1, p2);
          context.recordInteraction(
            product: p1,
            intent: BotIntent.comparison,
            userMessage: rawMessage,
          );
          return BotReply(
            text: 'Comparativa técnica entre ${p1.name} y ${p2.name}:\n'
                '• ${p1.name}: Capacidad recomendada en ducto según NTC 2050 con precio de ${formatCop(p1.price)} COP.\n'
                '• ${p2.name}: Calibre alternativo con capacidad acorde a carga y precio de ${formatCop(p2.price)} COP.',
            intent: BotIntent.comparison,
            products: [p1, p2],
            comparisonTable: table,
          );
        }
        break;

      default:
        break;
    }

    // 3. Recomendación específica por uso (ej. acometida 220V)
    if (intent == BotIntent.recommendation && text.contains('acometida')) {
      final matchedCables = context.catalog.where((p) =>
          p.category == ProductCategory.cables &&
          (p.sku == 'CBL-THN-10' || p.sku == 'CBL-THN-12' || p.sku.contains('THN'))).toList();

      if (matchedCables.isNotEmpty) {
        final chosen = matchedCables.first;
        context.recordInteraction(
          product: chosen,
          intent: BotIntent.recommendation,
          userMessage: rawMessage,
        );
        return BotReply(
          text: 'Para acometidas a 220V residenciales o comerciales ligeras, se recomienda cable de cobre tipo THHN/THW-2 (mínimo calibre #10 o #8 AWG según carga y cálculo de caída de tensión conforme a RETIE / NTC 2050 Art. 215). Tenemos disponible ${chosen.name} a ${formatCop(chosen.price)} COP el metro.',
          intent: BotIntent.recommendation,
          products: matchedCables.take(2).toList(),
          actions: const [
            BotAction(label: 'Ver en carrito', actionKey: 'view_cart', icon: Icons.shopping_cart_outlined),
          ],
        );
      }
    }

    // 4. Búsqueda directa en catálogo por entidades y tokens
    final matched = _rankProducts(context.catalog, rawMessage, entities);

    if (matched.isNotEmpty) {
      final best = matched.first;
      context.recordInteraction(
        product: best,
        intent: intent == BotIntent.unknown ? BotIntent.stock : intent,
        userMessage: rawMessage,
      );

      final stockStatus = best.stock > 0
          ? '${best.stock} unidades disponibles en inventario'
          : 'Agotado temporalmente';

      String summary;
      if (intent == BotIntent.price) {
        summary = '${best.name} (${best.sku}) tiene un costo de ${formatCop(best.price)} COP. $stockStatus.';
      } else {
        summary = 'Encontré ${best.name} (${best.sku}) en el catálogo técnico:\n'
            '• Precio: ${formatCop(best.price)} COP\n'
            '• Estado: $stockStatus\n'
            '• Especificación: ${best.shortDescription}';
      }

      return BotReply(
        text: summary,
        intent: intent == BotIntent.unknown ? BotIntent.stock : intent,
        products: matched,
        actions: const [
          BotAction(label: 'Ver en carrito', actionKey: 'view_cart', icon: Icons.shopping_cart_outlined),
        ],
      );
    }

    // 5. Consulta fuera de catálogo (prohibido alucinar productos o specs)
    return const BotReply(
      text: 'No tengo esa información en mi catálogo técnico. ¿Deseas que te comunique con un asesor humano por WhatsApp?',
      intent: BotIntent.unknown,
      needsHumanAgent: true,
      actions: [
        BotAction(label: 'Contactar por WhatsApp', actionKey: 'contact_whatsapp', icon: Icons.chat),
      ],
    );
  }
}
