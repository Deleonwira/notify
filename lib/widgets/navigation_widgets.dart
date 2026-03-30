import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/calendar_screen.dart';

class NavigationWidgets extends StatelessWidget {
  const NavigationWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text("Menu")),

          ListTile(
            title: const Text("Home"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(title: "Home")),
              );
            },
          ),

          ListTile(
            title: const Text("Calendar Notes"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarScreen(title: "Calendar Notes"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
