import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../explore/explore_screen.dart';
import '../video_rooms/video_room_screen.dart';
import '../communities/communities_screen.dart';
import '../chat/chat_screen.dart';
import '../events/events_screen.dart';
import '../profile/profile_screen.dart';
import '../movies/group_movies_screen.dart';
import '../notifications/notification_service.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    ExploreScreen(),
    CommunitiesScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        indicatorColor: const Color(0xFF4A7C6F).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Comunidades'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ApiClient _api = ApiClient();
  List<dynamic> _liveRooms = [];
  List<dynamic> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _api.get('/api/rooms?live=true'),
        _api.get('/api/events'),
      ]);
      if (mounted) {
        setState(() {
          _liveRooms = results[0] is List ? results[0] : [];
          _events = results[1] is List ? results[1] : [];
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
      case 'cultura': return '🎭';
      case 'jogos': return '🎮';
      default: return '☕';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Olá! 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('O que vamos fazer hoje?', style: TextStyle(color: Colors.grey, fontSize: 15)),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Consumer<NotificationService>(
                                builder: (context, service, _) => Badge(
                                  isLabelVisible: service.unreadCount > 0,
                                  label: Text('${service.unreadCount}'),
                                  child: const Icon(Icons.notifications_outlined),
                                ),
                              ),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 24),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Salas ao vivo', null),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: _liveRooms.isEmpty
                          ? const Center(child: Text('Nenhuma sala ao vivo', style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: _liveRooms.length,
                              separatorBuilder: (_, b) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final room = _liveRooms[index];
                                return _LiveRoomCard(
                                  room: room,
                                  category: _categoryIcon(room['category']),
                                );
                              },
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 28),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Próximos eventos', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
                    }),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: _events.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(child: Text('Nenhum evento', style: TextStyle(color: Colors.grey))),
                          )
                        : SliverList.separated(
                            itemCount: _events.take(3).length,
                            separatorBuilder: (_, b) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return _EventCard(event: _events[index]);
                            },
                          ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 28),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Filmes em grupo', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupMoviesScreen()));
                    }),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        children: [
                          _RecommendedCard(title: 'Introvertidos', subtitle: 'Café online', icon: '☕', color: const Color(0xFFF5F0E8)),
                          const SizedBox(width: 12),
                          _RecommendedCard(title: 'Cinema', subtitle: 'Filmes em grupo', icon: '🎬', color: const Color(0xFFE8F0F5)),
                          const SizedBox(width: 12),
                          _RecommendedCard(title: 'Música', subtitle: 'Sessão acústica', icon: '🎵', color: const Color(0xFFF0E8F5)),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Ver todos', style: TextStyle(color: Color(0xFF4A7C6F))),
            ),
        ],
      ),
    );
  }
}

class _LiveRoomCard extends StatelessWidget {
  final dynamic room;
  final String category;

  const _LiveRoomCard({required this.room, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => VideoRoomScreen(
            roomId: room['id'],
            title: room['title'] ?? '',
            isHost: false,
          ),
        ));
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A7C6F), Color(0xFF1A535C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A7C6F).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: const TextStyle(fontSize: 36)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 6),
                      SizedBox(width: 4),
                      Text('AO VIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              room['title'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.people_outline, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${room['participant_count'] ?? room['participants']?.length ?? 0} participantes',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final dynamic event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = event['event_date'] ?? '';
    String timeLabel = '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        final now = DateTime.now();
        final diff = dt.difference(now).inDays;
        if (diff == 0) {
          timeLabel = 'Hoje • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } else if (diff == 1) {
          timeLabel = 'Amanhã • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } else if (diff < 7) {
          timeLabel = 'Em $diff dias';
        } else {
          timeLabel = '${dt.day}/${dt.month}';
        }
      } catch (_) {
        timeLabel = dateStr;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF4A7C6F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event, color: Color(0xFF4A7C6F)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(timeLabel, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;

  const _RecommendedCard({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
