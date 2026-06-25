import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class EventsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> _events = [];
  bool _loading = false;
  String? _error;

  List<dynamic> get events => _events;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadEvents() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/api/events');
      _events = data is List ? data : [];
    } catch (e) {
      _error = 'Erro ao carregar eventos';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      await _api.post('/api/events/$eventId/join');
      await loadEvents();
    } catch (e) {
      _error = 'Erro ao participar do evento';
      notifyListeners();
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      await _api.delete('/api/events/$eventId/leave');
      await loadEvents();
    } catch (e) {
      _error = 'Erro ao sair do evento';
      notifyListeners();
    }
  }

  Future<void> createEvent({
    required String title,
    String? description,
    required DateTime eventDate,
    String? imageUrl,
    bool isSeasonal = false,
  }) async {
    try {
      await _api.post('/api/events', body: {
        'title': title,
        'description': description,
        'eventDate': eventDate.toIso8601String(),
        'imageUrl': imageUrl,
        'isSeasonal': isSeasonal,
      });
      await loadEvents();
    } catch (e) {
      _error = 'Erro ao criar evento';
      notifyListeners();
    }
  }
}
