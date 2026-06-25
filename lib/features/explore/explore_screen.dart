import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../video_rooms/video_room_screen.dart';
import '../video_rooms/create_room_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final data = await _api.get('/api/rooms?live=true');
      if (mounted) {
        setState(() {
          _rooms = data is List ? data : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _categoryIcon(String? category) {
    switch (category) {
      case 'cafe': return '☕';
      case 'filmes': return '🎬';
      case 'musica': return '🎵';
      case 'conversas': return '💬';
      case 'cultura': return '🇧🇷';
      case 'jogos': return '🎮';
      default: return '☕';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
        backgroundColor: const Color(0xFF4A7C6F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar sala'),
      ),
      body: SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
          : RefreshIndicator(
              onRefresh: _loadRooms,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explorar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Encontre salas e experiências para você.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar salas, eventos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Categorias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _CategoryCard(icon: '☕', label: 'Café', color: const Color(0xFFF5F0E8)),
                        _CategoryCard(icon: '🎬', label: 'Filmes', color: const Color(0xFFE8F0F5)),
                        _CategoryCard(icon: '🎵', label: 'Música', color: const Color(0xFFF0E8F5)),
                        _CategoryCard(icon: '💬', label: 'Conversas profundas', color: const Color(0xFFF5E8E8)),
                        _CategoryCard(icon: '🇧🇷', label: 'Cultura brasileira', color: const Color(0xFFF5F5E8)),
                        _CategoryCard(icon: '🎮', label: 'Jogos', color: const Color(0xFFE8F5E8)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Salas ao vivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (_rooms.isEmpty)
                      const Center(child: Text('Nenhuma sala ao vivo', style: TextStyle(color: Colors.grey)))
                    else
                      ..._rooms.map((room) => _PopularRoomTile(
                            room: room,
                            category: _categoryIcon(room['category']),
                          )),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _CategoryCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoRoomScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PopularRoomTile extends StatelessWidget {
  final dynamic room;
  final String category;

  const _PopularRoomTile({required this.room, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(category, style: const TextStyle(fontSize: 28)),
        title: Text(room['title'] ?? ''),
        subtitle: Row(
          children: [
            const Icon(Icons.circle, color: Colors.red, size: 8),
            const SizedBox(width: 4),
            Text('${room['participant_count'] ?? room['participants']?.length ?? 0} online'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => VideoRoomScreen(
                roomId: room['id'],
                title: room['title'] ?? '',
                isHost: false,
              ),
            ));
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: const Text('Entrar'),
        ),
      ),
    );
  }
}
