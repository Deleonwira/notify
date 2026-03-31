import 'package:flutter/material.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final Color color;
  final String? category;

  Note({
    this.id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.color = const Color(0xFF007AFF),
    this.category,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'color': color.value,
      'category': category,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      color: Color(map['color'] as int),
      category: map['category'] as String?,
    );
  }
}
