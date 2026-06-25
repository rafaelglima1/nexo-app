import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class RoomsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> _rooms = [];
  bool _loading = false;
  String? _error;

  List<dynamic> get rooms => _rooms;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadRooms({bool liveOnly = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/api/rooms${liveOnly ? '?live=true' : ''}');
      _rooms = data is List ? data : [];
    } catch (e) {
      _error = 'Erro ao carregar salas';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await _api.post('/api/rooms/$roomId/join');
      await loadRooms();
    } catch (e) {
      _error = 'Erro ao entrar na sala';
      notifyListeners();
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await _api.delete('/api/rooms/$roomId/leave');
      await loadRooms();
    } catch (e) {
      _error = 'Erro ao sair da sala';
      notifyListeners();
    }
  }

  Future<void> createRoom({
    required String title,
    String? description,
    String category = 'cafe',
    int maxParticipants = 8,
    List<String>? guidedQuestions,
  }) async {
    try {
      await _api.post('/api/rooms', body: {
        'title': title,
        'description': description,
        'category': category,
        'maxParticipants': maxParticipants,
        'guidedQuestions': guidedQuestions,
      });
      await loadRooms();
    } catch (e) {
      _error = 'Erro ao criar sala';
      notifyListeners();
    }
  }
}
