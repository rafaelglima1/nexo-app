import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import 'community_detail_screen.dart';
import 'create_community_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _communities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    try {
      final data = await _api.get('/api/communities');
      if (mounted) {
        setState(() {
          _communities = data is List ? data : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityScreen())),
        backgroundColor: const Color(0xFF4A7C6F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar comunidade'),
      ),
      body: SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
          : RefreshIndicator(
              onRefresh: _loadCommunities,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Comunidades', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Encontre pessoas com interesses em comum.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar comunidades...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_communities.isEmpty)
                      const Center(child: Text('Nenhuma comunidade ainda', style: TextStyle(color: Colors.grey)))
                    else
                      ..._communities.map((c) => _CommunityCard(
                            name: c['name'] ?? '',
                            description: c['description'] ?? '',
                            members: c['member_count'] ?? 0,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommunityDetailScreen(
                                  communityId: c['id'],
                                  name: c['name'] ?? '',
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final String name;
  final String description;
  final int members;
  final VoidCallback? onTap;

  const _CommunityCard({
    required this.name,
    required this.description,
    required this.members,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7C6F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group, color: Color(0xFF4A7C6F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('$members membros', style: const TextStyle(color: Color(0xFF4A7C6F), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
