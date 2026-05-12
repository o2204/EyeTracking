import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;
  final Color iconColor;
  final String category; // 'admin', 'system', 'power', 'weather'

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isUnread = false,
    required this.iconColor,
    required this.category,
  });
}
