import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import 'chat_conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final data = await _api.get('/api/chat/conversations');
      if (mounted) {
        setState(() {
          _conversations = data is List ? data : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _conversationName(dynamic conv) {
    if (conv['name'] != null && conv['name'].toString().isNotEmpty) return conv['name'];
    final participants = conv['participants'];
    if (participants is List && participants.isNotEmpty) {
      return participants.map((p) => p['users']?['name'] ?? 'Usuário').join(', ');
    }
    return 'Conversa';
  }

  String _lastMessage(dynamic conv) {
    final msg = conv['last_message'];
    if (msg is Map) return msg['content'] ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_square, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar conversas...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
                : _conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('Nenhuma conversa ainda', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(
                              'Inicie uma conversa em uma sala!',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _conversations.length,
                          separatorBuilder: (_, b) => Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (context, index) {
                            final conv = _conversations[index];
                            final name = _conversationName(conv);
                            final lastMsg = _lastMessage(conv);
                            final isGroup = conv['is_group'] == true;
                            return _ChatTile(
                              name: name,
                              lastMessage: lastMsg,
                              isGroup: isGroup,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatConversationScreen(
                                    name: name,
                                    conversationId: conv['id'],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final bool isGroup;
  final VoidCallback? onTap;

  const _ChatTile({
    required this.name,
    required this.lastMessage,
    this.isGroup = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isGroup
                ? [const Color(0xFF4A7C6F), const Color(0xFF1A535C)]
                : [const Color(0xFF4A7C6F), const Color(0xFF6B9E8F)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isGroup
              ? const Icon(Icons.group, color: Colors.white, size: 22)
              : Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
    );
  }
}
