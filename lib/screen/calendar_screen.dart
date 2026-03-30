import 'package:flutter/material.dart';
import '../widgets/navigation_widgets.dart';

class CalendarScreen extends StatelessWidget {
  final String title;

  const CalendarScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const NavigationWidgets(),
      body: const Center(child: Text('Welcome to the Calendar Page!')),
    );
  }
}
