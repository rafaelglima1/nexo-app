import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class CommunitiesProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<dynamic> _communities = [];
  bool _loading = false;
  String? _error;

  List<dynamic> get communities => _communities;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadCommunities() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/api/communities');
      _communities = data is List ? data : [];
    } catch (e) {
      _error = 'Erro ao carregar comunidades';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> joinCommunity(String communityId) async {
    try {
      await _api.post('/api/communities/$communityId/join');
      await loadCommunities();
    } catch (e) {
      _error = 'Erro ao entrar na comunidade';
      notifyListeners();
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    try {
      await _api.delete('/api/communities/$communityId/leave');
      await loadCommunities();
    } catch (e) {
      _error = 'Erro ao sair da comunidade';
      notifyListeners();
    }
  }

  Future<void> createCommunity({
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      await _api.post('/api/communities', body: {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
      });
      await loadCommunities();
    } catch (e) {
      _error = 'Erro ao criar comunidade';
      notifyListeners();
    }
  }
}
