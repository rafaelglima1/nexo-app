import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api/api_client.dart';

class ChatConversationScreen extends StatefulWidget {
  final String name;
  final String? conversationId;

  const ChatConversationScreen({super.key, required this.name, this.conversationId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _controller = TextEditingController();
  final _messages = <ChatMessage>[];
  final ApiClient _api = ApiClient();
  RealtimeChannel? _channel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }

  void _loadMessages() {
    if (widget.conversationId == null) {
      _loadMockMessages();
      return;
    }

    _api.get('/api/chat/conversations/${widget.conversationId}/messages?limit=100').then((response) {
      final list = response is List ? response : [];
      setState(() {
        _messages.clear();
        for (final item in list) {
          _messages.add(ChatMessage.fromMap(item));
        }
        _loading = false;
      });
    }).catchError((_) {
      _loadMockMessages();
    });
  }

  void _loadMockMessages() {
    setState(() {
      _messages.addAll([
        ChatMessage(text: 'Oi! Tudo bem?', isMe: false, time: '21:00'),
        ChatMessage(text: 'Oi! Tudo ótimo, e você?', isMe: true, time: '21:01'),
        ChatMessage(text: 'Bom demais! Gostei muito da sala de ontem', isMe: false, time: '21:02'),
        ChatMessage(text: 'Eu também! Vamos participar de novo hoje?', isMe: true, time: '21:03'),
      ]);
      _loading = false;
    });
  }

  void _subscribeToMessages() {
    final supabase = Supabase.instance.client;
    if (widget.conversationId == null) return;

    _channel = supabase
        .channel('messages:${widget.conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: widget.conversationId,
          ),
          callback: (payload) {
            final message = ChatMessage.fromMap(payload.newRecord);
            setState(() => _messages.add(message));
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now().format(context);

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true, time: now));
    });
    _controller.clear();

    if (widget.conversationId != null) {
      try {
        await _api.post('/api/chat/messages', body: {
          'conversationId': widget.conversationId,
          'content': text,
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A7C6F),
              child: Text(widget.name.isNotEmpty ? widget.name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: const TextStyle(fontSize: 16)),
                const Text('Online', style: TextStyle(fontSize: 12, color: Color(0xFF4A7C6F))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: msg.isMe
                                ? const Color(0xFF4A7C6F)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                              bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.time,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: msg.isMe ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        hintText: 'Mensagem...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A7C6F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
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

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String());
    return ChatMessage(
      text: map['content'] ?? '',
      isMe: false,
      time: '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
    );
  }
}
