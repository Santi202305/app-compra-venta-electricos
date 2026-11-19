import 'package:flutter/material.dart';
import '../models/product.dart';

/// Intenciones reconocidas por el asistente técnico.
enum BotIntent {
  price,
  stock,
  recommendation,
  comparison,
  shipping,
  payment,
  warranty,
  hours,
  agent,
  greeting,
  unknown,
}

/// Acción accionable dentro del chat (enlace a pantalla o acción externa).
class BotAction {
  final String label;
  final String actionKey;
  final IconData icon;

  const BotAction({
    required this.label,
    required this.actionKey,
    required this.icon,
  });
}

/// Respuesta estructurada generada por el bot.
class BotReply {
  final String text;
  final BotIntent intent;
  final List<Product> products;
  final Map<String, List<String>>? comparisonTable;
  final List<BotAction> actions;
  final bool needsHumanAgent;

  const BotReply({
    required this.text,
    required this.intent,
    this.products = const [],
    this.comparisonTable,
    this.actions = const [],
    this.needsHumanAgent = false,
  });
}

/// Contexto de la conversación para permitir seguimiento contextual.
class BotContext {
  final List<Product> catalog;
  Product? lastMentionedProduct;
  String? lastMentionedCategory;
  BotIntent? lastIntent;
  final List<String> messageHistory;

  BotContext({
    required this.catalog,
    this.lastMentionedProduct,
    this.lastMentionedCategory,
    this.lastIntent,
    List<String>? messageHistory,
  }) : messageHistory = messageHistory ?? [];

  void recordInteraction({
    Product? product,
    String? category,
    BotIntent? intent,
    String? userMessage,
  }) {
    if (product != null) lastMentionedProduct = product;
    if (category != null) lastMentionedCategory = category;
    if (intent != null) lastIntent = intent;
    if (userMessage != null) messageHistory.add(userMessage);
  }

  void resetContext() {
    lastMentionedProduct = null;
    lastMentionedCategory = null;
    lastIntent = null;
    messageHistory.clear();
  }
}

/// Contrato abstracto para el servicio del chatbot.
/// Permite reemplazar el motor local por un LLM o servicio en la nube sin modificar la UI.
abstract class BotService {
  Future<BotReply> reply(String message, BotContext context);
}
