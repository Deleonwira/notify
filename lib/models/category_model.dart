import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final Color color;
  final int iconCodePoint;

  Category({
    this.id,
    required this.name,
    this.color = const Color(0xFF7C3AED),
    required this.iconCodePoint,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color.value,
      'iconCodePoint': iconCodePoint,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      iconCodePoint: map['iconCodePoint'] as int,
    );
  }
}
