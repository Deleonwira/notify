import 'package:flutter/material.dart';

enum ActivityType { todo, event, reminder }

enum ActivityPriority { none, low, medium, high }

class SubTask {
  int? id;
  String title;
  bool isCompleted;

  SubTask({this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }
}

class Activity {
  final int? id;
  final String title;
  final ActivityType type;
  final DateTime date;
  bool isCompleted;

  // Pro Features
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final ActivityPriority priority;
  final List<SubTask> subTasks;

  Activity({
    this.id,
    required this.title,
    required this.type,
    required this.date,
    this.isCompleted = false,
    this.description,
    this.startTime,
    this.endTime,
    this.priority = ActivityPriority.none,
    List<SubTask>? subTasks,
  }) : subTasks = subTasks ?? [];

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'type': type.name,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'priority': priority.name,
    };
  }

  factory Activity.fromMap(
    Map<String, dynamic> map, [
    List<SubTask>? subTasks,
  ]) {
    return Activity(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: ActivityType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
      description: map['description'] as String?,
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'] as String)
          : null,
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      priority: ActivityPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ActivityPriority.none,
      ),
      subTasks: subTasks,
    );
  }

  Color get color {
    switch (type) {
      case ActivityType.todo:
        return const Color(0xFF7C3AED); // Apple Blue
      case ActivityType.event:
        return const Color(0xFFA855F7); // Apple Orange
      case ActivityType.reminder:
        return const Color(0xFFC084FC); // Apple Pink/Red
    }
  }

  Color get priorityColor {
    switch (priority) {
      case ActivityPriority.none:
        return Colors.transparent;
      case ActivityPriority.low:
        return const Color(0xFFD8B4FE); // Light priority
      case ActivityPriority.medium:
        return const Color(0xFFE9D5FF); // Medium priority
      case ActivityPriority.high:
        return const Color(0xFFFF3B30); // High priority
    }
  }

  double get progress {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    int completedCount = subTasks.where((st) => st.isCompleted).length;
    return completedCount / subTasks.length;
  }
}
