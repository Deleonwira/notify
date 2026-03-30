import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'montserrat',
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const HomeScreen(title: "Home"),
    );
  }
}
