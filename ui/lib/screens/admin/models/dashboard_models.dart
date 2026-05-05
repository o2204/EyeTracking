import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String room;
  final String status;
  final String device;
  final String time;

  const UserModel({
    required this.name,
    required this.room,
    required this.status,
    required this.device,
    required this.time,
  });
}

class EmergencyLogModel {
  final String user;
  final String room;
  final String time;
  final String status;

  const EmergencyLogModel({
    required this.user,
    required this.room,
    required this.time,
    required this.status,
  });
}

class SystemStatusModel {
  final String name;
  final bool online;

  const SystemStatusModel({
    required this.name,
    required this.online,
  });
}

class StatModel {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatModel({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class QuickActionModel {
  final String label;
  final IconData icon;
  final Color color;

  const QuickActionModel({
    required this.label,
    required this.icon,
    required this.color,
  });
}
