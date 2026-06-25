import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import 'create_event_screen.dart';
import 'events_provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents();
    });
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
    return Consumer<EventsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Eventos')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen())),
            backgroundColor: const Color(0xFFC4795B),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Criar evento'),
          ),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
              : provider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text(provider.error!, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => provider.loadEvents(),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  : provider.events.isEmpty
                      ? const Center(child: Text('Nenhum evento disponível', style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: () => provider.loadEvents(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.events.length,
                            itemBuilder: (context, index) {
                              final event = provider.events[index];
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
                                    onPressed: () => isJoined
                                        ? provider.leaveEvent(event['id'])
                                        : provider.joinEvent(event['id']),
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
      },
    );
  }
}
