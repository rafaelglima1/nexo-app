import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final data = await _api.get('/api/events');
      if (mounted) {
        setState(() {
          _events = data is List ? data : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinLeave(dynamic event) async {
    final isJoined = event['is_joined'] == true;
    try {
      if (isJoined) {
        await _api.delete('/api/events/${event['id']}/leave');
      } else {
        await _api.post('/api/events/${event['id']}/join');
      }
      _loadEvents();
    } catch (_) {}
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen())),
        backgroundColor: const Color(0xFFC4795B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar evento'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
          : _events.isEmpty
              ? const Center(child: Text('Nenhum evento disponível', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      final isSeasonal = event['is_seasonal'] == true;
                      final isJoined = event['is_joined'] == true;
                      final participantCount = event['participant_count'] ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSeasonal
                                  ? const Color(0xFFC4795B).withValues(alpha: 0.1)
                                  : const Color(0xFF4A7C6F).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSeasonal ? Icons.celebration : Icons.event,
                              color: isSeasonal ? const Color(0xFFC4795B) : const Color(0xFF4A7C6F),
                            ),
                          ),
                          title: Text(event['title'] ?? ''),
                          subtitle: Text('${_formatDate(event['event_date'])} • $participantCount participantes'),
                          trailing: ElevatedButton(
                            onPressed: () => _joinLeave(event),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 36),
                            ),
                            child: Text(isJoined ? 'Sair' : 'Participar'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
