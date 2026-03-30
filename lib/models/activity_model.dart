import 'package:flutter/material.dart';

enum ActivityType { todo, event, reminder }

class Activity {
  final String id;
  final String title;
  final ActivityType type;
  final DateTime date;
  bool isCompleted;

  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.isCompleted = false,
  });

  Color get color {
    switch (type) {
      case ActivityType.todo:
        return const Color(0xFF007AFF); // Apple Blue
      case ActivityType.event:
        return const Color(0xFFFF9500); // Apple Orange
      case ActivityType.reminder:
        return const Color(0xFFFF2D55); // Apple Pink/Red
    }
  }
}
