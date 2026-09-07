import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

/// Catálogo de ejemplo. En la versión real esto vendrá del backend
/// (Spring Boot + PostgreSQL) a través de una llamada REST; por ahora
/// se deja como datos locales para poder navegar la app sin backend.
final List<Product> kProducts = [
  Product(
    id: 1,
    category: ProductCategory.proteccion,
    name: 'Breaker DIN 20A Bipolar',
    sku: 'BRK-220-20A',
    price: 38900,
    color: const Color(0xFFF0EBFF),
    icon: Icons.bolt,
  ),
  Product(
    id: 2,
    category: ProductCategory.cables,
    name: 'Cable THHN #12 AWG (m)',
    sku: 'CBL-THN-12',
    price: 3200,
    color: const Color(0xFFE3F0FF),
    icon: Icons.cable,
  ),
  Product(
    id: 3,
    category: ProductCategory.iluminacion,
    name: 'Panel LED 18W Redondo',
    sku: 'LED-PN-18W',
    price: 16500,
    color: const Color(0xFFFFF8E1),
    icon: Icons.lightbulb_outline,
  ),
  Product(
    id: 4,
    category: ProductCategory.herramientas,
    name: 'Multímetro Digital CAT III',
    sku: 'HTL-MULT-3',
    price: 64900,
    color: const Color(0xFFEEF1F4),
    icon: Icons.speed,
  ),
  Product(
    id: 5,
    category: ProductCategory.proteccion,
    name: 'Totalizador 2x40A',
    sku: 'BRK-TOT-40A',
    price: 52000,
    color: const Color(0xFFF0EBFF),
    icon: Icons.bolt,
  ),
  Product(
    id: 6,
    category: ProductCategory.cables,
    name: 'Cable Encauchetado 3x14',
    sku: 'CBL-ENC-314',
    price: 5400,
    color: const Color(0xFFE3F0FF),
    icon: Icons.cable,
  ),
];

const int kShippingCost = 12000;

/// Respuestas del bot de preguntas frecuentes (misma lógica del
/// prototipo, ahora tipada en Dart).
class BotAnswer {
  final String label;
  final String text;
  const BotAnswer(this.label, this.text);
}

final Map<String, BotAnswer> kBotAnswers = {
  'horario': const BotAnswer(
    '🕒 Horario de atención',
    'Atendemos de lunes a viernes de 7:30 a.m. a 6:00 p.m. y sábados de '
        '8:00 a.m. a 2:00 p.m. Domingos y festivos cerrado.',
  ),
  'envios': const BotAnswer(
    '🚚 Tiempo de envío',
    'Los envíos locales llegan el mismo día si pides antes de las 2:00 '
        'p.m. A otros municipios, de 1 a 3 días hábiles.',
  ),
  'pagos': const BotAnswer(
    '💳 Métodos de pago',
    'Aceptamos Nequi, tarjeta débito/crédito, transferencia bancaria y '
        'pago contraentrega (Efecty).',
  ),
  'garantia': const BotAnswer(
    '🛠️ Garantía',
    'Todos los productos tienen garantía de 12 meses por defectos de '
        'fábrica. Herramientas: 6 meses. Guarda tu factura.',
  ),
  'devolucion': const BotAnswer(
    '↩️ Cambios/devoluciones',
    'Tienes 5 días hábiles para cambios con el producto sin usar y la '
        'factura original.',
  ),
  'asesor': const BotAnswer(
    '🙋 Hablar con un asesor',
    'Listo, te conecto con un asesor humano. Tiempo estimado de '
        'respuesta: 3 minutos.',
  ),
};
