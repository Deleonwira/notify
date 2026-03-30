import 'package:flutter/material.dart';
import "../models/note_models.dart";
import "../models/activity_model.dart";

final List<String> categories = ["All", "Work", "Personal", "Ideas", "Study"];

final List<Note> dummyNotes = [
  Note(
    title: "Meeting Notes",
    content:
        "Discuss project milestones and deadlines with the team. Review Q2 goals.",
    createdAt: DateTime(2026, 3, 28, 10, 30),
    color: const Color(0xFF007AFF),
  ),
  Note(
    title: "Grocery List",
    content: "Milk, Eggs, Bread, Butter, Fresh vegetables, Olive oil",
    createdAt: DateTime(2026, 3, 29, 14, 0),
    color: const Color(0xFF34C759),
  ),
  Note(
    title: "Flutter Ideas",
    content:
        "Explore new widgets and state management techniques. Try Riverpod.",
    createdAt: DateTime(2026, 3, 30, 9, 15),
    color: const Color(0xFFFF9500),
  ),
  Note(
    title: "Book Recommendations",
    content: "Atomic Habits, Deep Work, The Pragmatic Programmer",
    createdAt: DateTime(2026, 3, 27, 16, 45),
    color: const Color(0xFFAF52DE),
  ),
  Note(
    title: "Weekend Plans",
    content: "Visit the new cafe downtown. Go hiking if weather permits.",
    createdAt: DateTime(2026, 3, 26, 11, 0),
    color: const Color(0xFFFF2D55),
  ),
];

final List<Activity> dummyActivities = [
  Activity(
    id: "1",
    title: "Buy groceries for dinner",
    type: ActivityType.todo,
    date: DateTime.now(),
    isCompleted: false,
  ),
  Activity(
    id: "2",
    title: "Project Meeting with Client",
    type: ActivityType.event,
    date: DateTime.now(),
  ),
  Activity(
    id: "3",
    title: "Drink Water",
    type: ActivityType.reminder,
    date: DateTime.now(),
  ),
];
