import 'package:flutter/material.dart';

import '../data/products.dart';
import '../theme/app_theme.dart';

class _Bubble {
  final String text;
  final bool isMe;
  const _Bubble(this.text, this.isMe);
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<_Bubble> _messages = [
    const _Bubble(
      '¡Hola! 👋 Soy el asistente virtual. Elige una pregunta frecuente '
      'o escribe tu duda.',
      false,
    ),
  ];
  final Set<String> _askedTopics = {};
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  void _askTopic(String key) {
    if (_askedTopics.contains(key)) return;
    final answer = kBotAnswers[key]!;
    setState(() {
      _askedTopics.add(key);
      _messages.add(_Bubble(answer.label, true));
      _messages.add(_Bubble(answer.text, false));
    });
    _scrollToBottom();
  }

  void _sendFreeText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    final lower = text.toLowerCase();
    String response = '¡Gracias por tu mensaje! Un asesor te atenderá '
        'pronto. Mientras tanto, puedes usar las preguntas rápidas. 😊';
    if (lower.contains('precio') || lower.contains('costo')) {
      response = 'Puedes consultar los precios directamente en el '
          'catálogo; ya incluyen IVA. 💰';
    } else if (lower.contains('hola')) {
      response = '¡Hola! ¿En qué puedo ayudarte hoy?';
    } else if (lower.contains('gracias')) {
      response = '¡Con gusto! Aquí estaré si necesitas algo más. 😊';
    }

    setState(() {
      _messages.add(_Bubble(text, true));
      _messages.add(_Bubble(response, false));
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente virtual')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final bubble = _messages[index];
                return Align(
                  alignment: bubble.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: bubble.isMe
                          ? AppColors.accent
                          : AppColors.mistLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      bubble.text,
                      style: TextStyle(
                        color: bubble.isMe ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: kBotAnswers.entries.map((entry) {
                final disabled = _askedTopics.contains(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(entry.value.label),
                    onPressed: disabled ? null : () => _askTopic(entry.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendFreeText(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendFreeText,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
