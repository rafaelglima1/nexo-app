import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityId;
  final String name;

  const CommunityDetailScreen({super.key, required this.communityId, required this.name});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final ApiClient _api = ApiClient();
  Map<String, dynamic>? _community;
  bool _loading = true;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    try {
      final data = await _api.get('/api/communities/${widget.communityId}');
      if (mounted) {
        setState(() {
          _community = data;
          _isMember = data['is_member'] == true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleMembership() async {
    try {
      if (_isMember) {
        await _api.delete('/api/communities/${widget.communityId}/leave');
      } else {
        await _api.post('/api/communities/${widget.communityId}/join');
      }
      _loadCommunity();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A7C6F), Color(0xFF1A535C)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.people, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${_community?['member_count'] ?? 0} membros',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _toggleMembership,
                          icon: Icon(_isMember ? Icons.check : Icons.add),
                          label: Text(_isMember ? 'Participando' : 'Participar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4A7C6F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Sobre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _community?['description'] ?? 'Sem descrição',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text('Membros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMembersList(),
                  const SizedBox(height: 24),
                  const Text('Regras da comunidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const _RuleTile(number: 1, text: 'Respeite todos os membros'),
                  const _RuleTile(number: 2, text: 'Sem discriminação ou preconceito'),
                  const _RuleTile(number: 3, text: 'Conteúdo apropriado apenas'),
                  const _RuleTile(number: 4, text: 'Denuncie comportamentos inadequados'),
                ],
              ),
            ),
    );
  }

  Widget _buildMembersList() {
    final members = _community?['members'];
    if (members is! List || members.isEmpty) {
      return const Text('Nenhum membro ainda', style: TextStyle(color: Colors.grey));
    }
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final user = member['users'];
          final name = user?['name'] ?? 'U';
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4A7C6F),
                  child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final int number;
  final String text;

  const _RuleTile({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF4A7C6F),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
