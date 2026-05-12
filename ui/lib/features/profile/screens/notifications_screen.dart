import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'EyeTracking Welcome',
      message: 'Welcome to the future of interaction! Explore your dashboard to get started.',
      time: '2 hours ago',
      icon: Icons.mail_outline,
      iconColor: AppTheme.primary,
      isUnread: true,
      category: 'system',
    ),
    NotificationModel(
      id: '2',
      title: 'Admin Notification',
      message: 'Admin: Your account security settings have been successfully verified.',
      time: '5 hours ago',
      icon: Icons.admin_panel_settings_outlined,
      iconColor: Colors.blueAccent,
      isUnread: true,
      category: 'admin',
    ),
    NotificationModel(
      id: '3',
      title: 'Power Saving Alert',
      message: 'Save Power: Eye tracking sensitivity reduced to optimize battery performance.',
      time: '1 day ago',
      icon: Icons.battery_saver_outlined,
      iconColor: Colors.orangeAccent,
      isUnread: false,
      category: 'power',
    ),
    NotificationModel(
      id: '4',
      title: 'Weather Update',
      message: 'Weather Alert: Clear skies expected today in Cairo. Perfect for calibration!',
      time: '2 days ago',
      icon: Icons.wb_sunny_outlined,
      iconColor: Colors.yellowAccent,
      isUnread: false,
      category: 'weather',
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          time: _notifications[i].time,
          icon: _notifications[i].icon,
          iconColor: _notifications[i].iconColor,
          isUnread: false,
          category: _notifications[i].category,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primary),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return _NotificationCard(notification: notification);
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.isUnread 
            ? theme.cardColor.withValues(alpha: 0.9) 
            : theme.cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification.isUnread 
              ? AppTheme.primary.withValues(alpha: 0.3) 
              : Colors.white10,
          width: 1,
        ),
        boxShadow: notification.isUnread ? [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notification.iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (notification.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    notification.time,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
