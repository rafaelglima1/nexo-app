import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

enum NotificationType { event, friend, recommendation, social, seasonal }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.social,
      ),
      timestamp: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: map['is_read'] ?? false,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.event:
        return Icons.event;
      case NotificationType.friend:
        return Icons.person;
      case NotificationType.recommendation:
        return Icons.recommend;
      case NotificationType.social:
        return Icons.group;
      case NotificationType.seasonal:
        return Icons.celebration;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.event:
        return const Color(0xFF4A7C6F);
      case NotificationType.friend:
        return Colors.blue;
      case NotificationType.recommendation:
        return Colors.orange;
      case NotificationType.social:
        return Colors.purple;
      case NotificationType.seasonal:
        return const Color(0xFFC4795B);
    }
  }
}

class NotificationService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    try {
      final data = await _api.get('/api/notifications');
      final list = data is List ? data : [];
      _notifications.clear();
      for (final item in list) {
        _notifications.add(AppNotification.fromMap(item));
      }
      notifyListeners();
    } catch (_) {
      _loadMockNotifications();
    }
  }

  void _loadMockNotifications() {
    if (_notifications.isNotEmpty) return;

    _notifications.addAll([
      AppNotification(
        id: '1',
        title: 'Café da noite',
        body: 'Começa em 30 minutos! Participe da conversa.',
        type: NotificationType.event,
        timestamp: DateTime.now().add(const Duration(minutes: 30)),
      ),
      AppNotification(
        id: '2',
        title: 'Novo evento: Festa Junina Online',
        body: '24 de Junho, 20:00. Não perca!',
        type: NotificationType.event,
        timestamp: DateTime.now().add(const Duration(days: 7)),
      ),
      AppNotification(
        id: '3',
        title: 'Ana está online',
        body: 'Sua amiga está em uma sala. Diz oi!',
        type: NotificationType.friend,
        timestamp: DateTime.now(),
      ),
    ]);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await _api.patch('/api/notifications/$id/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();

    try {
      await _api.patch('/api/notifications/read-all');
    } catch (_) {}
  }
}
