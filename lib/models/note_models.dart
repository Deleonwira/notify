import 'package:flutter/material.dart';

class Note {
  final String title;
  final String content;
  final DateTime createdAt;
  final Color color;

  Note({
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.color = const Color(0xFF007AFF),
  }) : createdAt = createdAt ?? DateTime.now();
}
