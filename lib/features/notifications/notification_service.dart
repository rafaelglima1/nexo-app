import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {}

class NotificationService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final List<AppNotification> _notifications = [];
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerDeviceToken(token);
    }

    _messaging.onTokenRefresh.listen(_registerDeviceToken);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }

  Future<void> _registerDeviceToken(String token) async {
    try {
      await _api.post('/api/notifications/register', body: {'token': token});
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title ?? '',
      body: notification.body ?? '',
    );

    _notifications.insert(0, AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? '',
      body: notification.body ?? '',
      type: NotificationType.social,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> _showLocalNotification({required int id, required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'nexo_channel',
      'NEXO Notificações',
      channelDescription: 'Notificações do NEXO',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(id, title, body, details);
  }

  Future<void> loadNotifications() async {
    try {
      final data = await _api.get('/api/notifications');
      final list = data is List ? data : [];
      _notifications.clear();
      for (final item in list) {
        _notifications.add(AppNotification.fromMap(item));
      }
      notifyListeners();
    } catch (_) {}
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
