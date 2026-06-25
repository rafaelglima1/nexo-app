import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (service.unreadCount > 0)
            TextButton(
              onPressed: () => service.markAllAsRead(),
              child: const Text('Limpar tudo', style: TextStyle(color: Color(0xFF4A7C6F))),
            ),
        ],
      ),
      body: service.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Nenhuma notificação', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Quando algo acontecer, aparecerá aqui.', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: service.notifications.length,
              separatorBuilder: (_, b) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = service.notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () => service.markAsRead(notification.id),
                );
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFF4A7C6F).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? Colors.grey.shade100 : const Color(0xFF4A7C6F).withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notification.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notification.icon, color: notification.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A7C6F),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.timestamp),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);

    if (diff.isNegative) {
      if (diff.inMinutes > -60) return '${-diff.inMinutes}min atrás';
      if (diff.inHours > -24) return '${-diff.inHours}h atrás';
      if (diff.inDays > -7) return '${-diff.inDays}d atrás';
      return '${time.day}/${time.month}';
    }

    if (diff.inMinutes < 60) return 'Em ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Em ${diff.inHours}h';
    return '${time.day}/${time.month}';
  }
}
