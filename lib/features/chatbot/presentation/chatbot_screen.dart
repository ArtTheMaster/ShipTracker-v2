import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'chatbot_provider.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    ref.read(chatbotControllerProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatbotControllerProvider);
    final isTyping = ref.watch(isTypingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: AppColors.tealDark),
            SizedBox(width: 8),
            Text('Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navyPrimary,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Chip(label: Text('Typing...')),
                    ),
                  );
                }

                final msg = messages[index];
                return _buildMessageBubble(msg, context);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(msg, BuildContext context) {
    final isBot = !msg.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isBot ? Colors.white : AppColors.navyPrimary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isBot ? 0 : 16),
                bottomRight: Radius.circular(isBot ? 16 : 0),
              ),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: isBot ? Colors.black87 : Colors.white, fontSize: 14, height: 1.4),
            ),
          ),
          if (msg.actionRoute != null && msg.actionLabel != null) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealContainer, foregroundColor: AppColors.tealDark),
              onPressed: () {
                Navigator.pop(context); // Close chat
                context.push(msg.actionRoute!); // Deep link
              },
              icon: const Icon(Icons.touch_app, size: 16),
              label: Text(msg.actionLabel!),
            ),
          ],
          if (msg.quickReplies != null && msg.quickReplies!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: msg.quickReplies!.map<Widget>((reply) {
                return ActionChip(
                  label: Text(reply, style: const TextStyle(fontSize: 12, color: AppColors.navyPrimary)),
                  backgroundColor: Colors.indigo.shade50,
                  side: BorderSide.none,
                  onPressed: () => _handleSend(reply),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSend,
                decoration: InputDecoration(
                  hintText: 'Ask the assistant...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.navyPrimary,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () => _handleSend(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}