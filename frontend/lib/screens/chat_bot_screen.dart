import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/bot_service.dart';
import '../services/local_bot_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/stock_badge.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final BotReply? reply;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.reply,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Asistente virtual técnico local para electricistas y contratistas.
class ChatBotScreen extends StatefulWidget {
  final AppState app;
  final BotService? botService;

  const ChatBotScreen({
    super.key,
    required this.app,
    this.botService,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late final BotService _botService;
  late final BotContext _botContext;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;

  final List<_ChatMessage> _messages = [];

  static const List<Map<String, String>> _quickQuestions = [
    {'label': '🕒 Horario de atención', 'query': 'horario de atencion'},
    {'label': '🚚 Tiempos de envío', 'query': 'como son los envios a soacha y bogota'},
    {'label': '💳 Métodos de pago', 'query': 'puedo pagar contraentrega'},
    {'label': '⚡ Breakers 20A', 'query': 'tienen breakers de 20 amperios'},
    {'label': '🔌 Alambre #12', 'query': 'a como el metro de alambre 12'},
    {'label': '🛠️ Garantía', 'query': 'que garantia tienen las herramientas'},
    {'label': '🙋 Hablar con asesor', 'query': 'quiero hablar con un asesor'},
  ];

  @override
  void initState() {
    super.initState();
    _botService = widget.botService ?? const LocalBotService();
    _botContext = BotContext(catalog: widget.app.products);

    _messages.add(
      _ChatMessage(
        text: '¡Hola! ⚡ Soy tu Asistente Técnico Virtual de Electro Industrial.\n\n'
            'Puedo ayudarte a cotizar materiales, verificar calibres y amperajes, revisar disponibilidad en inventario o consultar especificaciones técnicas conforme a RETIE.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserMessage(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isProcessing) return;

    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _isProcessing = true;
    });
    _scrollToBottom();

    final botReply = await _botService.reply(trimmed, _botContext);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _messages.add(
          _ChatMessage(
            text: botReply.text,
            isUser: false,
            reply: botReply,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _handleAction(BotAction action) {
    if (action.actionKey == 'view_cart') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CartScreen(app: widget.app)),
      );
    } else if (action.actionKey == 'contact_whatsapp') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.chat, color: AppColors.success),
              SizedBox(width: 8),
              Text('Asesor Humano por WhatsApp'),
            ],
          ),
          content: const Text(
            'Línea de soporte técnico directo para contratistas:\n\n'
            '📱 WhatsApp: +57 (310) 890-2345\n'
            '⏰ Lunes a viernes: 7:30 a.m. – 6:00 p.m.\n\n'
            '¿Deseas iniciar chat con un ingeniero técnico?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conectando con asesor técnico en WhatsApp (+57 310 890-2345)...'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Abrir WhatsApp'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCompactProductCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: p.imageAsset != null
                      ? Image.asset(
                          p.imageAsset!,
                          fit: BoxFit.contain,
                          cacheWidth: 104,
                          cacheHeight: 104,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.mistLight,
                            child: const Icon(Icons.bolt, size: 24, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.mistLight,
                          child: const Icon(Icons.bolt, size: 24, color: AppColors.primary),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${p.sku}',
                      style: const TextStyle(fontSize: 11, color: AppColors.mist),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatCop(p.price),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StockBadge(product: p, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: p, app: widget.app),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(0, 32),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Ver detalle'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: p.stock > 0
                      ? () {
                          widget.app.cart.addProduct(p, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Agregado al carrito: ${p.name}'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Ir al carrito',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CartScreen(app: widget.app)),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 14),
                  label: const Text('Agregar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(0, 32),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(Map<String, List<String>> table) {
    final entries = table.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final col1Header = entries.first.value[0];
    final col2Header = entries.first.value[1];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: AppColors.primary,
            child: const Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Cuadro Comparativo Técnico',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 0.5),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.mistLight),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text('Característica', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(col1Header, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11), maxLines: 2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(col2Header, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11), maxLines: 2),
                  ),
                ],
              ),
              ...entries.skip(1).map((e) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10.5, color: AppColors.mist)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(e.value[0], style: const TextStyle(fontSize: 10.5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(e.value[1], style: const TextStyle(fontSize: 10.5)),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isMe = message.isUser;
    final reply = message.reply;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMe ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.ink,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  if (reply?.comparisonTable != null)
                    _buildComparisonTable(reply!.comparisonTable!),
                  if (reply != null && reply.products.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...reply.products.take(3).map((p) => _buildCompactProductCard(p)),
                  ],
                  if (reply != null && reply.actions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: reply.actions.map((act) {
                        return ActionChip(
                          avatar: Icon(act.icon, size: 16, color: AppColors.primary),
                          label: Text(act.label),
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          backgroundColor: AppColors.mistLight,
                          side: const BorderSide(color: AppColors.border),
                          onPressed: () => _handleAction(act),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.mistLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente Técnico Industrial',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, color: AppColors.success, size: 7),
                    SizedBox(width: 4),
                    Text(
                      'Motor Local Offline · Catálogo y RETIE',
                      style: TextStyle(fontSize: 11, color: AppColors.mist),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reiniciar conversación',
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              setState(() {
                _botContext.resetContext();
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    text: 'Conversación reiniciada. ¿Qué material o especificación técnica necesitas consultar?',
                    isUser: false,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isProcessing)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: AppColors.mistLight,
              color: AppColors.primary,
            ),
          Container(
            height: 44,
            color: AppColors.panel,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _quickQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    backgroundColor: AppColors.mistLight,
                    side: const BorderSide(color: AppColors.border),
                    label: Text(q['label']!),
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    onPressed: () => _handleUserMessage(q['query']!),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: AppColors.panel,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Pregunta por un calibre, breaker, norma o disponibilidad...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: _handleUserMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _handleUserMessage(_inputController.text),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
