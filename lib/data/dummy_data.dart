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
    color: const Color(0xFF7C3AED),
  ),
  Note(
    title: "Grocery List",
    content: "Milk, Eggs, Bread, Butter, Fresh vegetables, Olive oil",
    createdAt: DateTime(2026, 3, 29, 14, 0),
    color: const Color(0xFF9333EA),
  ),
  Note(
    title: "Flutter Ideas",
    content:
        "Explore new widgets and state management techniques. Try Riverpod.",
    createdAt: DateTime(2026, 3, 30, 9, 15),
    color: const Color(0xFFA855F7),
  ),
  Note(
    title: "Book Recommendations",
    content: "Atomic Habits, Deep Work, The Pragmatic Programmer",
    createdAt: DateTime(2026, 3, 27, 16, 45),
    color: const Color(0xFF8B5CF6),
  ),
  Note(
    title: "Weekend Plans",
    content: "Visit the new cafe downtown. Go hiking if weather permits.",
    createdAt: DateTime(2026, 3, 26, 11, 0),
    color: const Color(0xFFC084FC),
  ),
];

final List<Activity> dummyActivities = [
  Activity(
    id: 1,
    title: "Launch Pro Dashboard",
    type: ActivityType.todo,
    date: DateTime.now(),
    isCompleted: false,
    description: "Launch the all-new dashboard design for client approval.",
    priority: ActivityPriority.high,
    startTime: DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      9,
      0,
    ),
    endTime: DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      12,
      0,
    ),
    subTasks: [
      SubTask(id: 1, title: "Review UI components", isCompleted: true),
      SubTask(id: 2, title: "Test responsive layout", isCompleted: true),
      SubTask(id: 3, title: "Deploy to staging", isCompleted: false),
    ],
  ),
  Activity(
    id: 2,
    title: "Client Sync",
    type: ActivityType.event,
    date: DateTime.now(),
    priority: ActivityPriority.medium,
    startTime: DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      14,
      0,
    ),
    endTime: DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      15,
      0,
    ),
  ),
  Activity(
    id: 3,
    title: "Submit Expense Report",
    type: ActivityType.reminder,
    date: DateTime.now(),
    priority: ActivityPriority.low,
  ),
];
